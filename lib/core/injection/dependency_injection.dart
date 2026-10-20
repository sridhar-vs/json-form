import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:json_form/data/datasources/form_config_local_datasource.dart';
import 'package:json_form/data/repositories/form_repository_impl.dart';
import 'package:json_form/domain/repositories/form_repository.dart';
import 'package:json_form/domain/usecases/load_form_config.dart';
import 'package:json_form/domain/usecases/submit_form.dart';
import 'package:json_form/domain/usecases/validate_form.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:json_form/presentation/bloc/form_config/form_config_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({AssetBundle? assetBundle}) async {
  getIt
    ..registerLazySingleton(
      () => FormConfigLocalDataSource(assetBundle ?? rootBundle),
    )
    ..registerLazySingleton<FormRepository>(
      () => FormRepositoryImpl(getIt<FormConfigLocalDataSource>()),
    )
    ..registerLazySingleton(() => LoadFormConfig(getIt<FormRepository>()))
    ..registerLazySingleton(ValidateForm.new)
    ..registerLazySingleton(SubmitForm.new)
    ..registerFactory(() => FormConfigBloc(getIt<LoadFormConfig>()))
    ..registerFactory(
      () => DynamicFormBloc(
        validateForm: getIt<ValidateForm>(),
        submitForm: getIt<SubmitForm>(),
      ),
    );
}
