import 'package:json_form/core/error/exceptions.dart';
import 'package:json_form/data/models/field_config_model.dart';
import 'package:json_form/domain/entities/field_config_entity.dart';
import 'package:json_form/domain/entities/form_config_entity.dart';

class FormConfigModel {
  const FormConfigModel({
    required this.title,
    required this.submitButton,
    required this.fields,
  });

  factory FormConfigModel.fromJson(Map<String, dynamic> json) {
    final title = json['title'];
    final submitButton = json['submitButton'];
    final rawFields = json['fields'];
    if (title is! String || title.trim().isEmpty) {
      throw const FormConfigurationException(
        'The form configuration requires a non-empty title.',
      );
    }
    if (submitButton is! String || submitButton.trim().isEmpty) {
      throw const FormConfigurationException(
        'The form configuration requires a submitButton label.',
      );
    }
    if (rawFields is! List) {
      throw const FormConfigurationException(
        'The form configuration requires a fields array.',
      );
    }

    final fields = rawFields.map((raw) {
      if (raw is! Map<String, dynamic>) {
        throw const FormConfigurationException(
          'Each form field must be a JSON object.',
        );
      }
      return FieldConfigModel.fromJson(raw).toEntity();
    }).toList(growable: false);

    final ids = <String>{};
    for (final field in fields) {
      if (!ids.add(field.id)) {
        throw FormConfigurationException(
          'The field id "${field.id}" is duplicated.',
        );
      }
    }
    for (final field in fields) {
      final condition = field.visibleIf;
      if (condition != null && !ids.contains(condition.field)) {
        throw FormConfigurationException(
          'Visibility for "${field.id}" refers to unknown field "${condition.field}".',
        );
      }
      if (field.dependsOn != null && !ids.contains(field.dependsOn)) {
        throw FormConfigurationException(
          'Field "${field.id}" depends on unknown field "${field.dependsOn}".',
        );
      }
    }

    return FormConfigModel(
      title: title,
      submitButton: submitButton,
      fields: fields,
    );
  }

  final String title;
  final String submitButton;
  final List<FieldConfigEntity> fields;

  FormConfigEntity toEntity() => FormConfigEntity(
        title: title,
        submitButton: submitButton,
        fields: fields,
      );
}
