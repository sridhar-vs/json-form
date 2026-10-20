import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_form/core/error/exceptions.dart';
import 'package:json_form/data/datasources/form_config_local_datasource.dart';
import 'package:json_form/data/repositories/form_repository_impl.dart';

class _StringAssetBundle extends CachingAssetBundle {
  _StringAssetBundle(this.content);

  final String? content;

  @override
  Future<ByteData> load(String key) async {
    final value = content;
    if (value == null) throw FlutterError('Asset missing');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}

void main() {
  test('loads the parsed form through the repository', () async {
    final repository = FormRepositoryImpl(
      FormConfigLocalDataSource(
        _StringAssetBundle(
          '{"title":"Test","submitButton":"Save","fields":[]}',
        ),
      ),
    );

    final config = await repository.loadFormConfig();

    expect(config.title, 'Test');
    expect(config.submitButton, 'Save');
    expect(config.fields, isEmpty);
  });

  test(
    'maps missing assets and invalid JSON to configuration errors',
    () async {
      final missing = FormRepositoryImpl(
        FormConfigLocalDataSource(_StringAssetBundle(null)),
      );
      final invalid = FormRepositoryImpl(
        FormConfigLocalDataSource(_StringAssetBundle('{invalid')),
      );

      await expectLater(
        missing.loadFormConfig(),
        throwsA(isA<FormConfigurationException>()),
      );
      await expectLater(
        invalid.loadFormConfig(),
        throwsA(isA<FormConfigurationException>()),
      );
    },
  );
}
