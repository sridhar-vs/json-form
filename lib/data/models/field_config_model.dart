import 'package:json_form/core/error/exceptions.dart';
import 'package:json_form/domain/entities/field_config_entity.dart';

class FieldConfigModel {
  const FieldConfigModel(this.entity);

  factory FieldConfigModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final type = json['type'];
    final label = json['label'];
    if (id is! String || id.trim().isEmpty) {
      throw const FormConfigurationException(
        'Every field requires a non-empty id.',
      );
    }
    if (type is! String || type.trim().isEmpty) {
      throw FormConfigurationException('Field "$id" requires a type.');
    }
    if (label is! String || label.trim().isEmpty) {
      throw FormConfigurationException('Field "$id" requires a label.');
    }

    final requiredValue = json['required'] ?? false;
    if (requiredValue is! bool) {
      throw FormConfigurationException(
        'The required property on "$id" must be a boolean.',
      );
    }
    final visibleIf = _parseVisibility(id, json['visibleIf']);
    final dependsOn = json['dependsOn'];
    if (dependsOn != null && (dependsOn is! String || dependsOn.isEmpty)) {
      throw FormConfigurationException(
        'The dependsOn property on "$id" must be a non-empty string.',
      );
    }

    return FieldConfigModel(
      FieldConfigEntity(
        id: id,
        type: type,
        label: label,
        placeholder: _optionalString(id, 'placeholder', json['placeholder']),
        required: requiredValue,
        min: _optionalNumber(id, 'min', json['min']),
        max: _optionalNumber(id, 'max', json['max']),
        minLength: _optionalInt(id, 'minLength', json['minLength']),
        maxLength: _optionalInt(id, 'maxLength', json['maxLength']),
        divisions: _optionalInt(id, 'divisions', json['divisions']),
        options: _stringList(id, 'options', json['options']),
        allowedExtensions:
            _stringList(id, 'allowedExtensions', json['allowedExtensions']),
        visibleIf: visibleIf,
        dependsOn: dependsOn as String?,
        optionsMap: _optionsMap(id, json['optionsMap']),
      ),
    );
  }

  final FieldConfigEntity entity;

  FieldConfigEntity toEntity() => entity;

  static VisibilityCondition? _parseVisibility(
    String fieldId,
    Object? raw,
  ) {
    if (raw == null) return null;
    if (raw is! Map<String, dynamic>) {
      throw FormConfigurationException(
        'The visibleIf property on "$fieldId" must be an object.',
      );
    }
    final target = raw['field'];
    if (target is! String || target.isEmpty) {
      throw FormConfigurationException(
        'The visibleIf condition on "$fieldId" requires a field id.',
      );
    }
    final operators = [
      'equals',
      'notEquals',
      'contains',
      'isEmpty',
      'isNotEmpty',
    ];
    final operator = operators.firstWhere(
      raw.containsKey,
      orElse: () => '',
    );
    if (operator.isEmpty) {
      throw FormConfigurationException(
        'The visibleIf condition on "$fieldId" has no supported operator.',
      );
    }
    return VisibilityCondition(
      field: target,
      operator: operator,
      value: raw[operator],
    );
  }

  static String? _optionalString(String id, String key, Object? value) {
    if (value == null) return null;
    if (value is! String) {
      throw FormConfigurationException(
        'The $key property on "$id" must be a string.',
      );
    }
    return value;
  }

  static num? _optionalNumber(String id, String key, Object? value) {
    if (value == null) return null;
    if (value is! num) {
      throw FormConfigurationException(
        'The $key property on "$id" must be a number.',
      );
    }
    return value;
  }

  static int? _optionalInt(String id, String key, Object? value) {
    if (value == null) return null;
    if (value is! int) {
      throw FormConfigurationException(
        'The $key property on "$id" must be an integer.',
      );
    }
    return value;
  }

  static List<String> _stringList(
    String id,
    String key,
    Object? value,
  ) {
    if (value == null) return const [];
    if (value is! List || value.any((entry) => entry is! String)) {
      throw FormConfigurationException(
        'The $key property on "$id" must be an array of strings.',
      );
    }
    return List.unmodifiable(value.cast<String>());
  }

  static Map<String, List<String>> _optionsMap(
    String id,
    Object? value,
  ) {
    if (value == null) return const {};
    if (value is! Map<String, dynamic>) {
      throw FormConfigurationException(
        'The optionsMap property on "$id" must be an object.',
      );
    }
    final result = <String, List<String>>{};
    for (final entry in value.entries) {
      result[entry.key] = _stringList(id, 'optionsMap.${entry.key}', entry.value);
    }
    return Map.unmodifiable(result);
  }
}
