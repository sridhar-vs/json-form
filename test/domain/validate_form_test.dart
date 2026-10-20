import 'package:flutter_test/flutter_test.dart';
import 'package:json_form/domain/entities/field_config_entity.dart';
import 'package:json_form/domain/entities/form_config_entity.dart';
import 'package:json_form/domain/entities/form_submission_entity.dart';
import 'package:json_form/domain/usecases/validate_form.dart';
import 'package:json_form/domain/usecases/submit_form.dart';

import '../support/test_config.dart';

void main() {
  final config = testConfig();
  final validateForm = ValidateForm();

  test('validates required values while ignoring hidden fields', () {
    final errors = validateForm(
      config: config,
      values: {
        'country': 'India',
        'state': 'Tamil Nadu',
        'is_married': false,
        'spouse_name': null,
        'password': 'a-secure-password',
        'accept_terms': true,
      },
      visibility: {
        'country': true,
        'state': true,
        'is_married': true,
        'spouse_name': false,
        'password': true,
        'accept_terms': true,
      },
      availableOptions: {
        'country': ['India', 'USA'],
        'state': ['Tamil Nadu', 'Kerala'],
      },
    );

    expect(errors, isEmpty);
  });

  test('checks required terms and password length', () {
    final errors = validateForm(
      config: config,
      values: {
        'country': 'India',
        'state': 'Tamil Nadu',
        'is_married': false,
        'password': 'short',
        'accept_terms': false,
      },
      visibility: {
        for (final field in config.fields) field.id: field.id != 'spouse_name',
      },
      availableOptions: {
        'country': ['India', 'USA'],
        'state': ['Tamil Nadu', 'Kerala'],
      },
    );

    expect(errors['password'], 'Enter at least 8 characters.');
    expect(errors['accept_terms'], 'Please accept the Terms & Conditions.');
    expect(errors, isNot(contains('spouse_name')));
  });

  test('prepares output without hidden fields or passwords', () {
    final submission = SubmitForm()(
      config: config,
      values: {
        'country': 'India',
        'state': 'Tamil Nadu',
        'is_married': false,
        'spouse_name': 'Stale name',
        'password': 'secret',
        'accept_terms': true,
      },
      visibility: {
        for (final field in config.fields) field.id: field.id != 'spouse_name',
      },
    );

    expect(submission.values, containsPair('country', 'India'));
    expect(submission.values, containsPair('accept_terms', true));
    expect(submission.values, isNot(contains('password')));
    expect(submission.values, isNot(contains('spouse_name')));
  });

  test('enforces configured numeric minimum and maximum', () {
    const numberConfig = FormConfigEntity(
      title: 'Numeric form',
      submitButton: 'Submit',
      fields: [
        FieldConfigEntity(
          id: 'age',
          type: 'number',
          label: 'Age',
          min: 18,
          max: 60,
        ),
      ],
    );
    final errors = ValidateForm()(
      config: numberConfig,
      values: {'age': 17},
      visibility: const {'age': true},
    );

    expect(errors['age'], 'Enter a value of at least 18.');
  });

  test('serializes file metadata without exposing a local path', () {
    const fileConfig = FormConfigEntity(
      title: 'File form',
      submitButton: 'Submit',
      fields: [FieldConfigEntity(id: 'resume', type: 'file', label: 'Resume')],
    );
    final submission = SubmitForm()(
      config: fileConfig,
      values: {
        'resume': const FileMetadata(
          name: 'resume.pdf',
          extension: 'pdf',
          sizeBytes: 20,
          path: '/private/resume.pdf',
          isImage: false,
        ),
      },
      visibility: const {'resume': true},
    );

    expect(submission.values['resume'], {
      'name': 'resume.pdf',
      'extension': 'pdf',
      'sizeBytes': 20,
      'status': 'selected_not_uploaded',
    });
    expect(submission.values.toString(), isNot(contains('/private')));
  });
}
