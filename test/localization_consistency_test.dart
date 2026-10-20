import 'dart:convert';
import 'dart:io';

import 'package:calisync/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalogs = {
    for (final locale in AppLocalizations.supportedLocales)
      locale.languageCode: File('lib/l10n/app_${locale.languageCode}.arb'),
  };
  final template =
      jsonDecode(catalogs['it']!.readAsStringSync()) as Map<String, dynamic>;
  Set<String> messageKeys(Map<String, dynamic> catalog) =>
      catalog.keys.where((key) => !key.startsWith('@')).toSet();
  Set<String> placeholders(String message) =>
      RegExp(r'\{(\w+)').allMatches(message).map((match) => match[1]!).toSet();

  for (final entry in catalogs.entries) {
    test('${entry.key} translations match the template and contain no blanks', () {
      final source = entry.value.readAsStringSync();
      final catalog = jsonDecode(source) as Map<String, dynamic>;
      expect(messageKeys(catalog), messageKeys(template));
      // ARB top-level entries use two-space indentation. Check the source too:
      // jsonDecode alone silently accepts duplicate keys and keeps the last one.
      final declared = RegExp(
        r'^  "([^"\n]+)"\s*:',
        multiLine: true,
      ).allMatches(source).map((match) => match[1]!).toList();
      expect(declared.length, catalog.length);
      expect(declared.toSet().length, declared.length);
      for (final key in messageKeys(template)) {
        expect(catalog[key], isA<String>(), reason: key);
        expect((catalog[key] as String).trim(), isNotEmpty, reason: key);
        expect(
          placeholders(catalog[key] as String),
          placeholders(template[key] as String),
          reason: '$key must preserve its interpolation arguments',
        );
        final expectedMetadata = template['@$key'];
        if (expectedMetadata is Map &&
            expectedMetadata['placeholders'] != null) {
          expect(
            (catalog['@$key'] as Map?)?['placeholders'],
            expectedMetadata['placeholders'],
            reason: '$key must preserve argument names and types',
          );
        }
      }
      for (final key in catalog.keys.where(
        (key) => key.startsWith('@') && !key.startsWith('@@'),
      )) {
        expect(
          catalog.containsKey(key.substring(1)),
          isTrue,
          reason: '$key has no corresponding message',
        );
      }
      expect(catalog['appTitle'], 'Calisync');
      expect(catalog['registrationPrivacyNotice'], contains('Calisync'));
    });
  }
}
