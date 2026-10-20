import 'package:equatable/equatable.dart';
import 'package:json_form/domain/entities/form_config_entity.dart';
import 'package:json_form/domain/entities/form_submission_entity.dart';

enum FormSubmissionStatus { editing, submitting, invalid, success }

class DynamicFormState extends Equatable {
  DynamicFormState({
    this.config,
    Map<String, Object?> values = const {},
    Map<String, bool> visibility = const {},
    Map<String, List<String>> availableOptions = const {},
    Map<String, String> errors = const {},
    this.status = FormSubmissionStatus.editing,
    this.submission,
  })  : values = Map.unmodifiable(values),
        visibility = Map.unmodifiable(visibility),
        availableOptions = Map.unmodifiable({
          for (final entry in availableOptions.entries)
            entry.key: List<String>.unmodifiable(entry.value),
        }),
        errors = Map.unmodifiable(errors);

  final FormConfigEntity? config;
  final Map<String, Object?> values;
  final Map<String, bool> visibility;
  final Map<String, List<String>> availableOptions;
  final Map<String, String> errors;
  final FormSubmissionStatus status;
  final FormSubmissionEntity? submission;

  DynamicFormState copyWith({
    FormConfigEntity? config,
    Map<String, Object?>? values,
    Map<String, bool>? visibility,
    Map<String, List<String>>? availableOptions,
    Map<String, String>? errors,
    FormSubmissionStatus? status,
    FormSubmissionEntity? submission,
    bool clearSubmission = false,
  }) {
    return DynamicFormState(
      config: config ?? this.config,
      values: values ?? this.values,
      visibility: visibility ?? this.visibility,
      availableOptions: availableOptions ?? this.availableOptions,
      errors: errors ?? this.errors,
      status: status ?? this.status,
      submission: clearSubmission ? null : submission ?? this.submission,
    );
  }

  @override
  List<Object?> get props => [
        config,
        values,
        visibility,
        availableOptions,
        errors,
        status,
        submission,
      ];
}
