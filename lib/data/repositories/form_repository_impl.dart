import 'package:json_form/core/error/exceptions.dart';
import 'package:json_form/data/datasources/form_config_local_datasource.dart';
import 'package:json_form/domain/entities/form_config_entity.dart';
import 'package:json_form/domain/repositories/form_repository.dart';

class FormRepositoryImpl implements FormRepository {
  const FormRepositoryImpl(this.dataSource);

  final FormConfigLocalDataSource dataSource;

  @override
  Future<FormConfigEntity> loadFormConfig() async {
    try {
      return (await dataSource.loadConfig()).toEntity();
    } on FormConfigurationException {
      rethrow;
    }
  }
}
