import 'package:equatable/equatable.dart';

class VisibilityCondition extends Equatable {
  const VisibilityCondition({
    required this.field,
    required this.operator,
    this.value,
  });

  final String field;
  final String operator;
  final Object? value;

  bool evaluate(Map<String, Object?> values) {
    final actual = values[field];
    switch (operator) {
      case 'equals':
        return actual == value;
      case 'notEquals':
        return actual != value;
      case 'contains':
        return actual is Iterable && actual.contains(value);
      case 'isEmpty':
        return actual == null ||
            actual == false ||
            actual == '' ||
            (actual is Iterable && actual.isEmpty);
      case 'isNotEmpty':
        return actual != null &&
            actual != false &&
            actual != '' &&
            (actual is! Iterable || actual.isNotEmpty);
      default:
        return false;
    }
  }

  @override
  List<Object?> get props => [field, operator, value];
}

class FieldConfigEntity extends Equatable {
  const FieldConfigEntity({
    required this.id,
    required this.type,
    required this.label,
    this.placeholder,
    this.required = false,
    this.min,
    this.max,
    this.minLength,
    this.maxLength,
    this.divisions,
    this.options = const [],
    this.allowedExtensions = const [],
    this.visibleIf,
    this.dependsOn,
    this.optionsMap = const {},
  });

  final String id;
  final String type;
  final String label;
  final String? placeholder;
  final bool required;
  final num? min;
  final num? max;
  final int? minLength;
  final int? maxLength;
  final int? divisions;
  final List<String> options;
  final List<String> allowedExtensions;
  final VisibilityCondition? visibleIf;
  final String? dependsOn;
  final Map<String, List<String>> optionsMap;

  bool get isSensitive => type == 'password';

  @override
  List<Object?> get props => [
        id,
        type,
        label,
        placeholder,
        required,
        min,
        max,
        minLength,
        maxLength,
        divisions,
        options,
        allowedExtensions,
        visibleIf,
        dependsOn,
        optionsMap,
      ];
}
