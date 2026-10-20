import 'package:equatable/equatable.dart';
import 'package:json_form/domain/entities/form_config_entity.dart';

sealed class FormConfigState extends Equatable {
  const FormConfigState();

  @override
  List<Object?> get props => [];
}

final class FormConfigInitial extends FormConfigState {
  const FormConfigInitial();
}

final class FormConfigLoading extends FormConfigState {
  const FormConfigLoading();
}

final class FormConfigLoaded extends FormConfigState {
  const FormConfigLoaded(this.config);

  final FormConfigEntity config;

  @override
  List<Object?> get props => [config];
}

final class FormConfigError extends FormConfigState {
  const FormConfigError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
