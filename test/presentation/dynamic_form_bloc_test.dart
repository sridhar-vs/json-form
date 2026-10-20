import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_form/domain/usecases/submit_form.dart';
import 'package:json_form/domain/usecases/validate_form.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_state.dart';

import '../support/test_config.dart';

void main() {
  final config = testConfig();
  DynamicFormBloc createBloc() => DynamicFormBloc(
        validateForm: ValidateForm(),
        submitForm: SubmitForm(),
      );

  blocTest<DynamicFormBloc, DynamicFormState>(
    'updates dependent options and clears an invalid selection',
    build: createBloc,
    act: (bloc) async {
      bloc
        ..add(FormInitialized(config))
        ..add(const FieldValueChanged('country', 'India'))
        ..add(const FieldValueChanged('state', 'Kerala'))
        ..add(const FieldValueChanged('country', 'USA'));
    },
    expect: () => [
      isA<DynamicFormState>()
          .having((state) => state.availableOptions['state'], 'initial options', isEmpty),
      isA<DynamicFormState>()
          .having((state) => state.availableOptions['state'], 'India options', ['Tamil Nadu', 'Kerala']),
      isA<DynamicFormState>()
          .having((state) => state.values['state'], 'selected state', 'Kerala'),
      isA<DynamicFormState>()
          .having((state) => state.availableOptions['state'], 'USA options', ['Texas'])
          .having((state) => state.values['state'], 'cleared state', isNull),
    ],
  );

  blocTest<DynamicFormBloc, DynamicFormState>(
    'shows conditional fields and clears their values when hidden',
    build: createBloc,
    act: (bloc) async {
      bloc
        ..add(FormInitialized(config))
        ..add(const FieldValueChanged('is_married', true))
        ..add(const FieldValueChanged('spouse_name', 'Asha'))
        ..add(const FieldValueChanged('is_married', false));
    },
    expect: () => [
      isA<DynamicFormState>()
          .having((state) => state.visibility['spouse_name'], 'initial visibility', false),
      isA<DynamicFormState>()
          .having((state) => state.visibility['spouse_name'], 'visible', true),
      isA<DynamicFormState>()
          .having((state) => state.values['spouse_name'], 'entered name', 'Asha'),
      isA<DynamicFormState>()
          .having((state) => state.visibility['spouse_name'], 'hidden', false)
          .having((state) => state.values['spouse_name'], 'cleared name', isNull),
    ],
  );

  blocTest<DynamicFormBloc, DynamicFormState>(
    'blocks invalid submission and emits sanitized successful submission',
    build: createBloc,
    act: (bloc) async {
      bloc
        ..add(FormInitialized(config))
        ..add(const FormSubmitted())
        ..add(const FieldValueChanged('country', 'India'))
        ..add(const FieldValueChanged('state', 'Tamil Nadu'))
        ..add(const FieldValueChanged('password', 'password123'))
        ..add(const FieldValueChanged('accept_terms', true))
        ..add(const FormSubmitted());
    },
    expect: () => [
      isA<DynamicFormState>(),
      isA<DynamicFormState>()
          .having((state) => state.status, 'submitting', FormSubmissionStatus.submitting),
      isA<DynamicFormState>()
          .having((state) => state.status, 'invalid', FormSubmissionStatus.invalid),
      isA<DynamicFormState>(),
      isA<DynamicFormState>(),
      isA<DynamicFormState>(),
      isA<DynamicFormState>(),
      isA<DynamicFormState>()
          .having((state) => state.status, 'submitting', FormSubmissionStatus.submitting),
      isA<DynamicFormState>()
          .having((state) => state.status, 'success', FormSubmissionStatus.success)
          .having((state) => state.submission!.values, 'safe output',
              allOf(contains('country'), isNot(contains('password')))),
    ],
  );
}
