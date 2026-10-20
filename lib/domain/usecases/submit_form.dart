import 'package:json_form/domain/entities/form_config_entity.dart';
import 'package:json_form/domain/entities/form_submission_entity.dart';

class SubmitForm {
  FormSubmissionEntity call({
    required FormConfigEntity config,
    required Map<String, Object?> values,
    required Map<String, bool> visibility,
  }) {
    final output = <String, Object?>{};
    for (final field in config.fields) {
      if (visibility[field.id] == false || field.isSensitive) continue;
      final value = values[field.id];
      if (value is FileMetadata) {
        output[field.id] = value.toJson();
      } else if (field.type == 'number' && value is String) {
        output[field.id] = num.tryParse(value);
      } else if (value != null) {
        output[field.id] = value;
      }
    }
    return FormSubmissionEntity(output);
  }
}
