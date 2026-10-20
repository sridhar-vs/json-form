import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_form/core/error/exceptions.dart';
import 'package:json_form/domain/entities/form_config_entity.dart';
import 'package:json_form/domain/repositories/form_repository.dart';
import 'package:json_form/domain/usecases/load_form_config.dart' as usecases;
import 'package:json_form/presentation/bloc/form_config/form_config_bloc.dart';
import 'package:json_form/presentation/bloc/form_config/form_config_event.dart';
import 'package:json_form/presentation/bloc/form_config/form_config_state.dart';

class _FakeFormRepository implements FormRepository {
  _FakeFormRepository(this.result);

  final Object result;

  @override
  Future<FormConfigEntity> loadFormConfig() async {
    final value = result;
    if (value is FormConfigurationException) throw value;
    return value as FormConfigEntity;
  }
}

void main() {
  const config = FormConfigEntity(
    title: 'Test',
    submitButton: 'Submit',
    fields: [],
  );

  blocTest<FormConfigBloc, FormConfigState>(
    'emits loading and loaded states',
    build: () => FormConfigBloc(
      usecases.LoadFormConfig(_FakeFormRepository(config)),
    ),
    act: (bloc) => bloc.add(const LoadFormConfig()),
    expect: () => [
      const FormConfigLoading(),
      const FormConfigLoaded(config),
    ],
  );

  blocTest<FormConfigBloc, FormConfigState>(
    'emits a clear error state for invalid configuration',
    build: () => FormConfigBloc(
      usecases.LoadFormConfig(
        _FakeFormRepository(
          const FormConfigurationException('The JSON is invalid.'),
        ),
      ),
    ),
    act: (bloc) => bloc.add(const LoadFormConfig()),
    expect: () => [
      const FormConfigLoading(),
      const FormConfigError('The JSON is invalid.'),
    ],
  );
}
