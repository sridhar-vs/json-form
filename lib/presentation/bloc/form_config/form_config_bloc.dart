import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:json_form/core/error/exceptions.dart';
import 'package:json_form/domain/usecases/load_form_config.dart' as usecases;
import 'package:json_form/presentation/bloc/form_config/form_config_event.dart';
import 'package:json_form/presentation/bloc/form_config/form_config_state.dart';

class FormConfigBloc extends Bloc<FormConfigEvent, FormConfigState> {
  FormConfigBloc(this.loadFormConfig) : super(const FormConfigInitial()) {
    on<LoadFormConfig>(_onLoad);
  }

  final usecases.LoadFormConfig loadFormConfig;

  Future<void> _onLoad(
    LoadFormConfig event,
    Emitter<FormConfigState> emit,
  ) async {
    emit(const FormConfigLoading());
    try {
      emit(FormConfigLoaded(await loadFormConfig()));
    } on FormConfigurationException catch (error) {
      emit(FormConfigError(error.message));
    }
  }
}
