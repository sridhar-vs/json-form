import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:json_form/domain/entities/field_config_entity.dart';
import 'package:json_form/domain/usecases/submit_form.dart';
import 'package:json_form/domain/usecases/validate_form.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_state.dart';

class DynamicFormBloc extends Bloc<DynamicFormEvent, DynamicFormState> {
  DynamicFormBloc({
    required ValidateForm validateForm,
    required SubmitForm submitForm,
  })  : _validateForm = validateForm,
        _submitForm = submitForm,
        super(DynamicFormState()) {
    on<FormInitialized>(_onInitialized);
    on<FieldValueChanged>(_onFieldValueChanged);
    on<FieldValidationRequested>(_onFieldValidationRequested);
    on<FormValidationRequested>(_onFormValidationRequested);
    on<FormSubmitted>(_onSubmitted);
    on<FormResetRequested>(_onReset);
  }

  final ValidateForm _validateForm;
  final SubmitForm _submitForm;

  void _onInitialized(
    FormInitialized event,
    Emitter<DynamicFormState> emit,
  ) {
    final values = <String, Object?>{};
    for (final field in event.config.fields) {
      values[field.id] = switch (field.type) {
        'switch' || 'checkbox_single' => false,
        'checkbox' => <String>[],
        'slider' => field.min ?? 0,
        _ => null,
      };
    }
    final visibility = _evaluateVisibility(event.config.fields, values);
    _clearHiddenValues(event.config.fields, values, visibility);
    emit(
      DynamicFormState(
        config: event.config,
        values: values,
        visibility: visibility,
        availableOptions: _resolveOptions(event.config.fields, values),
      ),
    );
  }

  void _onFieldValueChanged(
    FieldValueChanged event,
    Emitter<DynamicFormState> emit,
  ) {
    final config = state.config;
    if (config == null || state.status == FormSubmissionStatus.submitting) {
      return;
    }
    final values = Map<String, Object?>.of(state.values)
      ..[event.fieldId] = event.value;
    final visibility = _evaluateVisibility(config.fields, values);
    _clearHiddenValues(config.fields, values, visibility);
    final options = _resolveOptions(config.fields, values);
    for (final field in config.fields.where((field) => field.dependsOn != null)) {
      final allowed = options[field.id] ?? const <String>[];
      if (values[field.id] != null && !allowed.contains(values[field.id])) {
        values[field.id] = null;
      }
    }
    final errors = Map<String, String>.of(state.errors)
      ..remove(event.fieldId);
    for (final field in config.fields.where(
      (field) => field.dependsOn == event.fieldId,
    )) {
      errors.remove(field.id);
    }
    for (final entry in visibility.entries) {
      if (!entry.value) errors.remove(entry.key);
    }
    emit(
      state.copyWith(
        values: values,
        visibility: visibility,
        availableOptions: options,
        errors: errors,
        status: FormSubmissionStatus.editing,
        clearSubmission: true,
      ),
    );
  }

  void _onFieldValidationRequested(
    FieldValidationRequested event,
    Emitter<DynamicFormState> emit,
  ) {
    final config = state.config;
    if (config == null) return;
    final validated = _validateForm(
      config: config,
      values: state.values,
      visibility: state.visibility,
      availableOptions: state.availableOptions,
    );
    final errors = Map<String, String>.of(state.errors)
      ..remove(event.fieldId);
    if (validated.containsKey(event.fieldId)) {
      errors[event.fieldId] = validated[event.fieldId]!;
    }
    emit(state.copyWith(errors: errors));
  }

  void _onFormValidationRequested(
    FormValidationRequested event,
    Emitter<DynamicFormState> emit,
  ) {
    final config = state.config;
    if (config == null) return;
    final errors = _validateForm(
      config: config,
      values: state.values,
      visibility: state.visibility,
      availableOptions: state.availableOptions,
    );
    emit(
      state.copyWith(
        errors: errors,
        status: errors.isEmpty
            ? FormSubmissionStatus.editing
            : FormSubmissionStatus.invalid,
      ),
    );
  }

  void _onSubmitted(
    FormSubmitted event,
    Emitter<DynamicFormState> emit,
  ) {
    final config = state.config;
    if (config == null || state.status == FormSubmissionStatus.submitting) {
      return;
    }
    emit(state.copyWith(status: FormSubmissionStatus.submitting));
    final errors = _validateForm(
      config: config,
      values: state.values,
      visibility: state.visibility,
      availableOptions: state.availableOptions,
    );
    if (errors.isNotEmpty) {
      emit(
        state.copyWith(
          errors: errors,
          status: FormSubmissionStatus.invalid,
        ),
      );
      return;
    }
    final submission = _submitForm(
      config: config,
      values: state.values,
      visibility: state.visibility,
    );
    emit(
      state.copyWith(
        errors: const {},
        status: FormSubmissionStatus.success,
        submission: submission,
      ),
    );
  }

  void _onReset(
    FormResetRequested event,
    Emitter<DynamicFormState> emit,
  ) {
    final config = state.config;
    if (config == null) return;
    _onInitialized(FormInitialized(config), emit);
  }

  Map<String, bool> _evaluateVisibility(
    List<FieldConfigEntity> fields,
    Map<String, Object?> values,
  ) {
    return {
      for (final field in fields)
        field.id: field.visibleIf?.evaluate(values) ?? true,
    };
  }

  void _clearHiddenValues(
    List<FieldConfigEntity> fields,
    Map<String, Object?> values,
    Map<String, bool> visibility,
  ) {
    for (final field in fields) {
      if (visibility[field.id] == false) {
        values[field.id] = switch (field.type) {
          'switch' || 'checkbox_single' => false,
          'checkbox' => <String>[],
          _ => null,
        };
      }
    }
  }

  Map<String, List<String>> _resolveOptions(
    List<FieldConfigEntity> fields,
    Map<String, Object?> values,
  ) {
    return {
      for (final field in fields)
        if (field.dependsOn == null)
          field.id: field.options
        else
          field.id: _dependentOptions(field, values[field.dependsOn]),
    };
  }

  List<String> _dependentOptions(
    FieldConfigEntity field,
    Object? parentValue,
  ) {
    if (parentValue is! String) return const [];
    return field.optionsMap[parentValue] ?? const [];
  }
}
