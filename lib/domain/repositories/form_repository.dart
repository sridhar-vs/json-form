import 'package:json_form/domain/entities/form_config_entity.dart';

abstract interface class FormRepository {
  Future<FormConfigEntity> loadFormConfig();
}
