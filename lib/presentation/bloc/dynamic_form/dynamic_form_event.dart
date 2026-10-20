import 'package:equatable/equatable.dart';
import 'package:json_form/domain/entities/form_config_entity.dart';

sealed class DynamicFormEvent extends Equatable {
  const DynamicFormEvent();

  @override
  List<Object?> get props => [];
}

final class FormInitialized extends DynamicFormEvent {
  const FormInitialized(this.config);

  final FormConfigEntity config;

  @override
  List<Object?> get props => [config];
}

final class FieldValueChanged extends DynamicFormEvent {
  const FieldValueChanged(this.fieldId, this.value);

  final String fieldId;
  final Object? value;

  @override
  List<Object?> get props => [fieldId, value];
}

final class FieldValidationRequested extends DynamicFormEvent {
  const FieldValidationRequested(this.fieldId);

  final String fieldId;

  @override
  List<Object?> get props => [fieldId];
}

final class FormValidationRequested extends DynamicFormEvent {
  const FormValidationRequested();
}

final class FormSubmitted extends DynamicFormEvent {
  const FormSubmitted();
}

final class FormResetRequested extends DynamicFormEvent {
  const FormResetRequested();
}
