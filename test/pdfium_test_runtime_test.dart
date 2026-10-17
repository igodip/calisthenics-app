import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/pdfium_test_runtime.dart';

void main() {
  late Directory temporary;
  setUp(
    () => temporary = Directory.systemTemp.createTempSync('pdfium-resolver-'),
  );
  tearDown(() => temporary.deleteSync(recursive: true));

  File asset(String name, {String os = 'linux', String architecture = 'x64'}) {
    final hook = Directory('${temporary.path}/$name')..createSync();
    final library = File('${hook.path}/libpdfium.so')
      ..writeAsStringSync('fixture');
    File('${hook.path}/input.json').writeAsStringSync(
      jsonEncode({
        'package_name': 'pdfium_dart',
        'config': {
          'extensions': {
            'code_assets': {
              'target_os': os,
              'target_architecture': architecture,
            },
          },
        },
      }),
    );
    File('${hook.path}/output.json').writeAsStringSync(
      jsonEncode({
        'status': 'success',
        'assets': [
          {
            'encoding': {
              'id': 'package:pdfium_dart/libpdfium',
              'file': library.path,
            },
          },
        ],
      }),
    );
    return library;
  }

  String resolve({String? configuredPath}) => resolvePdfiumTestLibrary(
    configuredPath: configuredPath,
    hooksDirectory: temporary,
    targetOs: 'linux',
    targetArchitecture: 'x64',
  );

  test('explicit path takes precedence over generated assets', () {
    asset('host');
    final explicit = File('${temporary.path}/explicit.so')
      ..writeAsStringSync('fixture');
    expect(resolve(configuredPath: explicit.path), explicit.absolute.path);
  });

  test('invalid explicit path fails rather than silently falling back', () {
    asset('host');
    expect(
      () => resolve(configuredPath: '${temporary.path}/missing.so'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('PDFIUM_PATH'),
        ),
      ),
    );
  });

  test(
    'discovers host asset and ignores Android or wrong-architecture assets',
    () {
      final host = asset('host');
      asset('android', os: 'android', architecture: 'arm64');
      asset('other-host', architecture: 'arm64');
      expect(resolve(), host.absolute.path);
    },
  );

  test('missing host asset fails with setup instructions', () {
    asset('android', os: 'android', architecture: 'arm64');
    expect(
      resolve,
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('No host PDFium library found for linux-x64'),
        ),
      ),
    );
  });

  test('ignores incomplete hook metadata and deleted assets', () {
    final deleted = asset('deleted')..deleteSync();
    expect(deleted.existsSync(), isFalse);
    Directory('${temporary.path}/incomplete').createSync();
    final host = asset('host');
    expect(resolve(), host.absolute.path);
  });
}
