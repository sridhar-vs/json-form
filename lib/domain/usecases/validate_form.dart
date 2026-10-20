import 'package:json_form/domain/entities/field_config_entity.dart';
import 'package:json_form/domain/entities/form_config_entity.dart';
import 'package:json_form/domain/entities/form_submission_entity.dart';

class ValidateForm {
  Map<String, String> call({
    required FormConfigEntity config,
    required Map<String, Object?> values,
    required Map<String, bool> visibility,
    Map<String, List<String>> availableOptions = const {},
  }) {
    final errors = <String, String>{};
    for (final field in config.fields) {
      if (visibility[field.id] == false) continue;
      final value = values[field.id];
      final error = _validateField(
        field,
        value,
        availableOptions[field.id] ?? field.options,
      );
      if (error != null) errors[field.id] = error;
    }
    return Map.unmodifiable(errors);
  }

  String? _validateField(
    FieldConfigEntity field,
    Object? value,
    List<String> availableOptions,
  ) {
    final empty = value == null ||
        value == '' ||
        (value is String && value.trim().isEmpty) ||
        (value is Iterable && value.isEmpty);
    if (empty) {
      return field.required ? 'This field is required.' : null;
    }

    if (field.required && field.type == 'checkbox_single' && value != true) {
      return 'Please accept the Terms & Conditions.';
    }
    if (field.required && field.type == 'switch' && value != true) {
      return 'This field is required.';
    }

    if (value is String) {
      if (field.minLength != null && value.length < field.minLength!) {
        return 'Enter at least ${field.minLength} characters.';
      }
      if (field.maxLength != null && value.length > field.maxLength!) {
        return 'Enter no more than ${field.maxLength} characters.';
      }
      if (field.type == 'email' &&
          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
        return 'Enter a valid email address.';
      }
      if (field.type == 'phone' &&
          !RegExp(r'^\+?[0-9\s().-]{7,15}$').hasMatch(value.trim())) {
        return 'Enter a valid phone number.';
      }
      if (field.type == 'date' && DateTime.tryParse(value) == null) {
        return 'Choose a valid date.';
      }
      if (field.type == 'time' &&
          !RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$').hasMatch(value)) {
        return 'Choose a valid time.';
      }
      if (field.type == 'dropdown' || field.type == 'radio') {
        if (!availableOptions.contains(value)) return 'Choose a valid option.';
      }
    }

    if (field.type == 'number' || field.type == 'slider') {
      final number = value is num ? value : num.tryParse(value.toString());
      if (number == null) return 'Enter a valid number.';
      if (field.min != null && number < field.min!) {
        return 'Enter a value of at least ${field.min}.';
      }
      if (field.max != null && number > field.max!) {
        return 'Enter a value no greater than ${field.max}.';
      }
    }

    if (field.type == 'checkbox' && value is List) {
      if (field.options.any((option) => !value.contains(option))) {
        return 'Choose valid options.';
      }
    }

    if ((field.type == 'file' || field.type == 'image') &&
        value is FileMetadata &&
        field.allowedExtensions.isNotEmpty &&
        !field.allowedExtensions
            .map((extension) => extension.toLowerCase())
            .contains(value.extension.toLowerCase())) {
      return 'Choose a file with an allowed extension.';
    }

    return null;
  }
}
