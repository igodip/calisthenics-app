
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:calisync/theme/app_theme.dart';

enum ExerciseType { squat, pushUp, pullUp, dip }

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

  // --- Exercise counting ---
  ExerciseType _selectedExercise = ExerciseType.squat;
  int _repCount = 0;
  bool _isContractedPosition = false;
  double? _currentKneeAngle;
  double? _currentElbowAngle;
  double? _currentPullUpRatio;
  String _exerciseStage = 'Top';
  static const double _squatDownThreshold = 100; // degrees
  static const double _squatUpThreshold = 160;   // degrees
  static const double _pushUpDownThreshold = 80; // degrees
  static const double _pushUpUpThreshold = 155;  // degrees
  static const double _dipDownThreshold = 85;    // degrees
  static const double _dipUpThreshold = 160;     // degrees
  static const double _pullUpTopThreshold = 0.15;    // ratio of torso length
  static const double _pullUpBottomThreshold = 0.6;  // ratio of torso length

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        model: PoseDetectionModel.accurate,
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
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noCameras)),
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cameraInitFailed('$e'))),
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

      if (_poseDetected) {
        _updateExerciseCount(_lastPose!);
      } else {
        _exerciseStage = 'No pose';
        _currentKneeAngle = null;
        _currentElbowAngle = null;
        _currentPullUpRatio = null;
        _isContractedPosition = false;
      }

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

  void _updateExerciseCount(Pose pose) {
    switch (_selectedExercise) {
      case ExerciseType.squat:
        _updateSquatCount(pose);
        break;
      case ExerciseType.pushUp:
        _updatePushUpCount(pose);
        break;
      case ExerciseType.pullUp:
        _updatePullUpCount(pose);
        break;
      case ExerciseType.dip:
        _updateDipCount(pose);
        break;
    }
  }

  double? _angleForJoints(
    Pose pose, {
    required PoseLandmarkType first,
    required PoseLandmarkType middle,
    required PoseLandmarkType last,
    double minLikelihood = 0.5,
  }) {
    final firstLm = pose.landmarks[first];
    final middleLm = pose.landmarks[middle];
    final lastLm = pose.landmarks[last];

    if (firstLm == null || middleLm == null || lastLm == null) return null;
    if (firstLm.likelihood < minLikelihood ||
        middleLm.likelihood < minLikelihood ||
        lastLm.likelihood < minLikelihood) {
      return null;
    }

    return _calculateAngle(firstLm, middleLm, lastLm);
  }

  void _updateSquatCount(Pose pose) {
    final leftAngle = _angleForJoints(
      pose,
      first: PoseLandmarkType.leftHip,
      middle: PoseLandmarkType.leftKnee,
      last: PoseLandmarkType.leftAnkle,
    );
    final rightAngle = _angleForJoints(
      pose,
      first: PoseLandmarkType.rightHip,
      middle: PoseLandmarkType.rightKnee,
      last: PoseLandmarkType.rightAnkle,
    );

    double? kneeAngle;
    if (leftAngle != null && rightAngle != null) {
      kneeAngle = (leftAngle + rightAngle) / 2.0;
    } else {
      kneeAngle = leftAngle ?? rightAngle;
    }

    if (kneeAngle == null) {
      _currentKneeAngle = null;
      _exerciseStage = 'Tracking…';
      return;
    }

    _currentKneeAngle = kneeAngle;
    _currentElbowAngle = null;
    _currentPullUpRatio = null;

    final isDown = kneeAngle < _squatDownThreshold;
    final isUp = kneeAngle > _squatUpThreshold;

    if (isDown && !_isContractedPosition) {
      _isContractedPosition = true;
      _exerciseStage = 'Bottom';
    } else if (isUp && _isContractedPosition) {
      _isContractedPosition = false;
      _repCount += 1;
      _exerciseStage = 'Top';
    } else {
      _exerciseStage = _isContractedPosition ? 'Bottom' : 'Top';
    }
  }

  void _updatePushUpCount(Pose pose) {
    final leftAngle = _angleForJoints(
      pose,
      first: PoseLandmarkType.leftShoulder,
      middle: PoseLandmarkType.leftElbow,
      last: PoseLandmarkType.leftWrist,
    );
    final rightAngle = _angleForJoints(
      pose,
      first: PoseLandmarkType.rightShoulder,
      middle: PoseLandmarkType.rightElbow,
      last: PoseLandmarkType.rightWrist,
    );

    double? elbowAngle;
    if (leftAngle != null && rightAngle != null) {
      elbowAngle = (leftAngle + rightAngle) / 2.0;
    } else {
      elbowAngle = leftAngle ?? rightAngle;
    }

    if (elbowAngle == null) {
      _currentElbowAngle = null;
      _exerciseStage = 'Tracking…';
      return;
    }

    _currentElbowAngle = elbowAngle;
    _currentKneeAngle = null;
    _currentPullUpRatio = null;

    final isDown = elbowAngle < _pushUpDownThreshold;
    final isUp = elbowAngle > _pushUpUpThreshold;

    if (isDown && !_isContractedPosition) {
      _isContractedPosition = true;
      _exerciseStage = 'Down';
    } else if (isUp && _isContractedPosition) {
      _isContractedPosition = false;
      _repCount += 1;
      _exerciseStage = 'Up';
    } else {
      _exerciseStage = _isContractedPosition ? 'Down' : 'Up';
    }
  }

  double? _torsoLength(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

    final lengths = <double>[];
    if (leftShoulder != null && leftHip != null &&
        leftShoulder.likelihood > 0.4 && leftHip.likelihood > 0.4) {
      lengths.add((leftHip.y - leftShoulder.y).abs());
    }
    if (rightShoulder != null && rightHip != null &&
        rightShoulder.likelihood > 0.4 && rightHip.likelihood > 0.4) {
      lengths.add((rightHip.y - rightShoulder.y).abs());
    }

    if (lengths.isEmpty) {
      return null;
    }
    return lengths.reduce((a, b) => a + b) / lengths.length;
  }

  void _updatePullUpCount(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    final ratios = <double>[];
    final torso = _torsoLength(pose);

    void addRatio(PoseLandmark? shoulder, PoseLandmark? wrist) {
      if (shoulder == null || wrist == null) return;
      if (torso == null || torso < 1) return;
      if (shoulder.likelihood < 0.4 || wrist.likelihood < 0.4) return;
      ratios.add((wrist.y - shoulder.y) / torso);
    }

    addRatio(leftShoulder, leftWrist);
    addRatio(rightShoulder, rightWrist);

    if (ratios.isEmpty) {
      _currentPullUpRatio = null;
      _exerciseStage = 'Tracking…';
      return;
    }

    final ratio = ratios.reduce((a, b) => a + b) / ratios.length;
    _currentPullUpRatio = ratio;
    _currentKneeAngle = null;
    _currentElbowAngle = null;

    final isTop = ratio < _pullUpTopThreshold;
    final isBottom = ratio > _pullUpBottomThreshold;

    if (isTop && !_isContractedPosition) {
      _isContractedPosition = true;
      _exerciseStage = 'Top';
    } else if (isBottom && _isContractedPosition) {
      _isContractedPosition = false;
      _repCount += 1;
      _exerciseStage = 'Bottom';
    } else {
      _exerciseStage = _isContractedPosition ? 'Top' : 'Bottom';
    }
  }

  void _updateDipCount(Pose pose) {
    final leftAngle = _angleForJoints(
      pose,
      first: PoseLandmarkType.leftShoulder,
      middle: PoseLandmarkType.leftElbow,
      last: PoseLandmarkType.leftWrist,
      minLikelihood: 0.4,
    );
    final rightAngle = _angleForJoints(
      pose,
      first: PoseLandmarkType.rightShoulder,
      middle: PoseLandmarkType.rightElbow,
      last: PoseLandmarkType.rightWrist,
      minLikelihood: 0.4,
    );

    double? elbowAngle;
    if (leftAngle != null && rightAngle != null) {
      elbowAngle = (leftAngle + rightAngle) / 2.0;
    } else {
      elbowAngle = leftAngle ?? rightAngle;
    }

    if (elbowAngle == null) {
      _currentElbowAngle = null;
      _exerciseStage = 'Tracking…';
      return;
    }

    _currentElbowAngle = elbowAngle;
    _currentKneeAngle = null;
    _currentPullUpRatio = null;

    final isDown = elbowAngle < _dipDownThreshold;
    final isUp = elbowAngle > _dipUpThreshold;

    if (isDown && !_isContractedPosition) {
      _isContractedPosition = true;
      _exerciseStage = 'Down';
    } else if (isUp && _isContractedPosition) {
      _isContractedPosition = false;
      _repCount += 1;
      _exerciseStage = 'Up';
    } else {
      _exerciseStage = _isContractedPosition ? 'Down' : 'Up';
    }
  }

  String _exerciseDisplayName(ExerciseType exercise) {
    switch (exercise) {
      case ExerciseType.squat:
        return 'Squat';
      case ExerciseType.pushUp:
        return 'Push-up';
      case ExerciseType.pullUp:
        return 'Pull-up';
      case ExerciseType.dip:
        return 'Dip';
    }
  }

  String _defaultStageForExercise(ExerciseType exercise) {
    switch (exercise) {
      case ExerciseType.squat:
        return 'Top';
      case ExerciseType.pushUp:
        return 'Up';
      case ExerciseType.pullUp:
        return 'Bottom';
      case ExerciseType.dip:
        return 'Up';
    }
  }

  void _resetExerciseState({bool resetReps = true}) {
    if (resetReps) {
      _repCount = 0;
    }
    _isContractedPosition = false;
    _currentKneeAngle = null;
    _currentElbowAngle = null;
    _currentPullUpRatio = null;
    _exerciseStage = _defaultStageForExercise(_selectedExercise);
  }

  double _calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final ab = Offset(a.x - b.x, a.y - b.y);
    final cb = Offset(c.x - b.x, c.y - b.y);

    final dot = ab.dx * cb.dx + ab.dy * cb.dy;
    final magAb = math.sqrt(ab.dx * ab.dx + ab.dy * ab.dy);
    final magCb = math.sqrt(cb.dx * cb.dx + cb.dy * cb.dy);
    if (magAb == 0 || magCb == 0) {
      return 180;
    }
    final cosAngle = (dot / (magAb * magCb)).clamp(-1.0, 1.0);
    final angle = math.acos(cosAngle);
    return angle * 180 / math.pi;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Scaffold(
        backgroundColor: colorScheme.onSurface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.onSurface,
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
                    boneColor: colorScheme.secondary,
                    jointColor: colorScheme.primary,
                    landmarkColors: {
                      PoseLandmarkType.leftEye: colorScheme.error,
                      PoseLandmarkType.rightEye: colorScheme.error,
                    },
                  ),
                ),
              _buildHud(context, l10n),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'resetReps',
            onPressed: () {
              setState(() {
                _resetExerciseState(resetReps: true);
              });
            },
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 12),
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

  Widget _buildHud(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>()!;
    final status = _poseDetected
        ? l10n.poseDetected
        : (_isBusy ? l10n.processing : l10n.idle);

    final landmarks = _lastPose?.landmarks.length ?? 0;
    final cameraLabel = _useFrontCamera ? l10n.cameraFront : l10n.cameraBack;
    final rotationLabel = _rotation.toString().split('.').last;
    final metricsText = l10n.hudMetrics(
      _fps.toStringAsFixed(1),
      _avgMs.toStringAsFixed(0),
      landmarks,
    );
    final orientationText =
        l10n.hudOrientation(rotationLabel, cameraLabel, _fmt);

    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatusDot(color: _poseDetected ? appColors.success : appColors.warning),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<ExerciseType>(
                      value: _selectedExercise,
                      dropdownColor: colorScheme.surface,
                      items: ExerciseType.values
                          .map(
                            (exercise) => DropdownMenuItem(
                              value: exercise,
                              child: Text(
                                _exerciseDisplayName(exercise),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null || value == _selectedExercise) return;
                        setState(() {
                          _selectedExercise = value;
                          _resetExerciseState(resetReps: true);
                        });
                      },
                    ),
                  ),
                  Text(
                    status,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    metricsText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    orientationText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_exerciseDisplayName(_selectedExercise)} reps: $_repCount  stage: $_exerciseStage',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_currentKneeAngle != null)
                    Text(
                      'knee angle: ${_currentKneeAngle!.toStringAsFixed(0)}°',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (_currentElbowAngle != null)
                    Text(
                      'elbow angle: ${_currentElbowAngle!.toStringAsFixed(0)}°',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (_currentPullUpRatio != null)
                    Text(
                      'arm extension: ${(_currentPullUpRatio! * 100).clamp(0, 300).toStringAsFixed(0)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
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
  final Color boneColor;
  final Color jointColor;
  final Map<PoseLandmarkType, Color> landmarkColors;

  PosePainter({
    required this.pose,
    required this.imageSize,
    required this.rotation,
    required this.isFrontCamera,
    required this.boneColor,
    required this.jointColor,
    required this.landmarkColors,
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

  @override
  void paint(Canvas canvas, Size size) {
    final bonePaint = Paint()
      ..color = boneColor
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

    Offset transform(Offset p) {
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
      final p1 = transform(Offset(a.x, a.y));
      final p2 = transform(Offset(b.x, b.y));
      canvas.drawLine(p1, p2, bonePaint);
    }

    // Draw points
    for (final entry in pose.landmarks.entries) {
      if (entry.value.likelihood < 0.8) continue;
      final p = transform(Offset(entry.value.x, entry.value.y));
      var paintColor = Paint()
        ..color = jointColor
        ..style = PaintingStyle.fill
        ..strokeWidth = 3;
      if (landmarkColors.containsKey(entry.value.type)) {
        paintColor.color = landmarkColors[entry.value.type]!;
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
