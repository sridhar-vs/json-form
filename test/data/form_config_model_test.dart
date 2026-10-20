import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_form/core/error/exceptions.dart';
import 'package:json_form/data/models/form_config_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses all configured fields and rules from the asset', () async {
    final json = jsonDecode(
      await rootBundle.loadString('assets/form_config.json'),
    ) as Map<String, dynamic>;
    final config = FormConfigModel.fromJson(json).toEntity();

    expect(config.title, 'Employee Registration Form');
    expect(config.submitButton, 'Submit');
    expect(config.fields, hasLength(19));
    expect(config.fields.first.minLength, 3);
    expect(config.fields.first.maxLength, 50);
    expect(config.fields.firstWhere((field) => field.id == 'spouse_name').visibleIf?.field,
        'is_married');
    expect(config.fields.firstWhere((field) => field.id == 'state').optionsMap['India'],
        ['Tamil Nadu', 'Kerala', 'Karnataka']);
  });

  test('rejects duplicate or empty field ids', () {
    final config = <String, dynamic>{
      'title': 'Form',
      'submitButton': 'Submit',
      'fields': [
        {'id': '', 'type': 'text', 'label': 'Empty'},
      ],
    };
    expect(
      () => FormConfigModel.fromJson(config),
      throwsA(isA<FormConfigurationException>()),
    );

    config['fields'] = [
      {'id': 'same', 'type': 'text', 'label': 'One'},
      {'id': 'same', 'type': 'text', 'label': 'Two'},
    ];
    expect(
      () => FormConfigModel.fromJson(config),
      throwsA(isA<FormConfigurationException>()),
    );
  });

  test('rejects missing required properties', () {
    expect(
      () => FormConfigModel.fromJson({
        'title': 'Form',
        'submitButton': 'Submit',
        'fields': [
          {'id': 'name', 'type': 'text'},
        ],
      }),
      throwsA(isA<FormConfigurationException>()),
    );
  });
}
