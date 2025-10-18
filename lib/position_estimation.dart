
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseCamPage extends StatefulWidget {
  const PoseCamPage({super.key});

  @override
  State<PoseCamPage> createState() => _PoseCamPageState();
}

class _StatusDot extends StatelessWidget {
  final Color color;
  const _StatusDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _PoseCamPageState extends State<PoseCamPage> with WidgetsBindingObserver {
  CameraController? _controller;
  late final PoseDetector _poseDetector;

  bool _isBusy = false;
  Pose? _lastPose;
  Size? _imageSize; // raw camera image size (unrotated)
  InputImageRotation _rotation = InputImageRotation.rotation0deg;
  bool _useFrontCamera = false;

  // --- HUD / stats ---
  bool _poseDetected = false;
  double _avgMs = 0;          // EMA of inference time
  double _fps = 0;            // updates ~1/s
  int _frames = 0;            // frames since last FPS tick
  DateTime? _lastFpsTick;
  String _fmt = '?';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        model: PoseDetectionModel.base,
        mode: PoseDetectionMode.stream,
      ),
    );
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller.stopImageStream();
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  int _deviceOrientationToDegrees(DeviceOrientation o) {
    switch (o) {
      case DeviceOrientation.portraitUp: return 0;
      case DeviceOrientation.landscapeLeft: return 90;
      case DeviceOrientation.portraitDown: return 180;
      case DeviceOrientation.landscapeRight: return 270;
    }
  }

  InputImageRotation _rotationFromDegrees(int degrees) {
    switch (degrees) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  void _updateRotation() {
    final v = _controller!.value;
    final sensor = _controller!.description.sensorOrientation;        // 0/90/180/270 (fixed per camera)
    final dev = _deviceOrientationToDegrees(v.deviceOrientation);     // changes as you rotate device

    // Derive the InputImageRotation expected by ML Kit:
    // Back camera: sensor - dev
    // Front camera: sensor + dev
    final deg = _useFrontCamera
        ? (sensor + dev) % 360
        : (sensor - dev + 360) % 360;
    _rotation = _rotationFromDegrees(deg);
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cameras available')),
          );
        }
        return;
      }
      final camera = cameras.firstWhere(
            (c) => _useFrontCamera
            ? c.lensDirection == CameraLensDirection.front
            : c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // Choose the best format per platform.
      final imgFmt = Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.nv21;

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: imgFmt,
      );

      await controller.initialize();
      _controller = controller;

      // compute once now…
      _updateRotation();

      // …and update whenever device orientation changes
      DeviceOrientation? last;
      _controller!.addListener(() {
        final cur = _controller!.value.deviceOrientation;
        if (last != cur) {
          last = cur;
          _updateRotation();
          if (mounted) setState(() {});
        }
      });

      await controller.startImageStream(_processCameraImage);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera init failed: $e')),
        );
      }
    }
  }

  // Optional: robust YUV420 -> NV21 conversion (if a device ignores requested NV21).
  Uint8List _yuv420ToNv21(CameraImage image) {
    final w = image.width;
    final h = image.height;
    final int ySize = w * h;
    final int uvSize = ySize ~/ 2;
    final out = Uint8List(ySize + uvSize);

    // Plane 0 is Y
    final Plane yP = image.planes[0];
    int outIndex = 0;
    for (int row = 0; row < h; row++) {
      final start = row * yP.bytesPerRow;
      out.setRange(outIndex, outIndex + w, yP.bytes.sublist(start, start + w));
      outIndex += w;
    }

    // Interleave V then U for NV21
    final Plane uP = image.planes[1];
    final Plane vP = image.planes[2];
    final int chromaHeight = h ~/ 2;
    final int chromaWidth = w ~/ 2;
    final int uRowStride = uP.bytesPerRow;
    final int vRowStride = vP.bytesPerRow;
    final int uPixelStride = uP.bytesPerPixel ?? 1;
    final int vPixelStride = vP.bytesPerPixel ?? 1;

    for (int row = 0; row < chromaHeight; row++) {
      for (int col = 0; col < chromaWidth; col++) {
        final int uIndex = row * uRowStride + col * uPixelStride;
        final int vIndex = row * vRowStride + col * vPixelStride;
        out[outIndex++] = vP.bytes[vIndex];
        out[outIndex++] = uP.bytes[uIndex];
      }
    }
    return out;
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    final t0 = DateTime.now();
    try {
      // Prepare bytes & metadata according to the actual format
      Uint8List bytes;
      InputImageFormat fmt;
      if (image.format.group == ImageFormatGroup.bgra8888) {
        // iOS
        final WriteBuffer wb = WriteBuffer();
        for (final p in image.planes) {
          wb.putUint8List(p.bytes);
        }
        bytes = wb.done().buffer.asUint8List();
        fmt = InputImageFormat.bgra8888;
        _fmt = 'bgra8888';
      } else if (image.format.group == ImageFormatGroup.nv21) {
        // Android NV21 (ideal path)
        final WriteBuffer wb = WriteBuffer();
        for (final p in image.planes) {
          wb.putUint8List(p.bytes);
        }
        bytes = wb.done().buffer.asUint8List();
        fmt = InputImageFormat.nv21;
        _fmt = 'nv21';
      } else {
        // Some devices still deliver yuv420; convert to NV21
        bytes = _yuv420ToNv21(image);
        fmt = InputImageFormat.nv21;
        _fmt = 'yuv420->nv21';
      }

      _imageSize = Size(image.width.toDouble(), image.height.toDouble());

      final inputImageData = InputImageMetadata(
        size: _imageSize!,
        rotation: _rotation, // computed from sensor + device + lens
        format: fmt,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageData);

      final poses = await _poseDetector.processImage(inputImage);
      _lastPose = poses.isNotEmpty ? poses.first : null;
      _poseDetected = _lastPose != null;

      // --- timing and fps ---
      final dtMs = DateTime.now().difference(t0).inMilliseconds.toDouble();
      _avgMs = _avgMs == 0 ? dtMs : (_avgMs * 0.85 + dtMs * 0.15);

      _frames += 1;
      final now = DateTime.now();
      if (_lastFpsTick == null || now.difference(_lastFpsTick!).inMilliseconds > 1000) {
        _fps = _frames / (now.difference(_lastFpsTick ?? now).inMilliseconds / 1000.0).clamp(0.001, double.infinity);
        _frames = 0;
        _lastFpsTick = now;
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('processImage error: $e');
      }
    } finally {
      _isBusy = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final preview = CameraPreview(controller);
          return Stack(
            fit: StackFit.expand,
            children: [
              // Use preview size as-is; CameraPreview handles its own rotation.
              FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: controller.value.previewSize!.height,
                  height: controller.value.previewSize!.width,
                  child: preview,
                ),
              ),
              if (_lastPose != null && _imageSize != null)
                CustomPaint(
                  painter: PosePainter(
                    pose: _lastPose!,
                    imageSize: _imageSize!,
                    rotation: _rotation,
                    isFrontCamera: _useFrontCamera,
                  ),
                ),
              _buildHud(),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'flip',
            onPressed: () async {
              _useFrontCamera = !_useFrontCamera;
              await _controller?.stopImageStream();
              await _controller?.dispose();
              _controller = null;
              if (mounted) setState(() {});
              _initCamera();
            },
            child: const Icon(Icons.cameraswitch),
          ),
        ],
      ),
    );
  }

  Widget _buildHud() {
    final status = _poseDetected
        ? 'Pose detected'
        : (_isBusy ? 'Processing…' : 'Idle');

    final landmarks = _lastPose?.landmarks.length ?? 0;

    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatusDot(color: _poseDetected ? Colors.greenAccent : Colors.orangeAccent),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(status, style: const TextStyle(color: Colors.white)),
                  Text('fps: ${_fps.toStringAsFixed(1)}  ms: ${_avgMs.toStringAsFixed(0)}  lmks: $landmarks',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('rot: ${describeEnum(_rotation)}  cam: ${_useFrontCamera ? 'front' : 'back'}  fmt: $_fmt',
                      style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final Pose pose;
  final Size imageSize; // raw camera image size (unrotated)
  final InputImageRotation rotation;
  final bool isFrontCamera;

  PosePainter({
    required this.pose,
    required this.imageSize,
    required this.rotation,
    required this.isFrontCamera,
  });

  // Pairs of landmarks to draw bones
  final List<List<PoseLandmarkType>> _bones = [
    // Torso
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    // Arms
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    // Legs
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    // Face lines (rough)
    [PoseLandmarkType.leftEye, PoseLandmarkType.rightEye],
    [PoseLandmarkType.leftEar, PoseLandmarkType.leftEye],
    [PoseLandmarkType.rightEar, PoseLandmarkType.rightEye],
    [PoseLandmarkType.nose, PoseLandmarkType.leftEye],
    [PoseLandmarkType.nose, PoseLandmarkType.rightEye],
  ];

  final _colors = {PoseLandmarkType.leftEye : Colors.red, PoseLandmarkType.rightEye: Colors.red};

  @override
  void paint(Canvas canvas, Size size) {
    final landmarkPaint = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;
    final bonePaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // IMPORTANT: ML Kit already accounts for 'rotation' when generating landmarks.
    // So landmarks are in the *rotated* image space. We should NOT rotate again.
    // We only need to: (a) choose the correct source size for scaling,
    // (b) mirror horizontally for the front camera to match the preview.

    // Source size after MLKit-applied rotation (swap w/h at 90/270)
    final Size src = (
        rotation == InputImageRotation.rotation90deg ||
            rotation == InputImageRotation.rotation270deg
    ) ? Size(imageSize.height, imageSize.width) : imageSize;

    // Match CameraPreview's BoxFit.cover: uniform scale + center
    final double s = (src.width / src.height) < (size.width / size.height)
        ? size.width / src.width
        : size.height / src.height;
    final double dx = (size.width - src.width * s) / 2.0;
    final double dy = (size.height - src.height * s) / 2.0;

    Offset _transform(Offset p) {
      double x = p.dx, y = p.dy;

      // Mirror after rotation space, so left/right match the on-screen preview
      if (isFrontCamera) {
        x = src.width - x;
      }

      // Scale + center
      return Offset(dx + x * s, dy + y * s);
    }

    // Draw bones
    for (final pair in _bones) {
      final a = pose.landmarks[pair[0]];
      final b = pose.landmarks[pair[1]];
      if (a == null || b == null) continue;
      if (a.likelihood < 0.5 || b.likelihood < 0.5) continue;
      final p1 = _transform(Offset(a.x, a.y));
      final p2 = _transform(Offset(b.x, b.y));
      canvas.drawLine(p1, p2, bonePaint);
    }

    // Draw points
    for (final entry in pose.landmarks.entries) {
      if (entry.value.likelihood < 0.8) continue;
      final p = _transform(Offset(entry.value.x, entry.value.y));
      var paintColor = Paint()
        ..color = Colors.lightBlueAccent
        ..style = PaintingStyle.fill
        ..strokeWidth = 3;
      if (_colors.containsKey(entry.value.type)) {
        paintColor.color = _colors[entry.value.type] as Color;
      }
      canvas.drawCircle(p, 4, paintColor);
      debugPrint("${entry.value.type} ${entry.value.likelihood}");
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.rotation != rotation ||
        oldDelegate.isFrontCamera != isFrontCamera ||
        oldDelegate.imageSize != imageSize;
  }
}
