import 'package:json_form/domain/entities/form_config_entity.dart';
import 'package:json_form/domain/repositories/form_repository.dart';

class LoadFormConfig {
  const LoadFormConfig(this.repository);

  final FormRepository repository;

  Future<FormConfigEntity> call() => repository.loadFormConfig();
}
