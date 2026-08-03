import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Verify zero imports of material.dart or cupertino.dart in example/lib/', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue);

    final dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    final forbiddenImports = [
      'package:flutter/material.dart',
      'package:flutter/cupertino.dart',
    ];

    final violations = <String>[];

    for (final file in dartFiles) {
      final lines = file.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final forbidden in forbiddenImports) {
          if (line.contains(forbidden)) {
            violations.add('File ${file.path}:${i + 1} contains "$forbidden"');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'example app MUST NOT import material.dart or cupertino.dart',
    );
  });
}
