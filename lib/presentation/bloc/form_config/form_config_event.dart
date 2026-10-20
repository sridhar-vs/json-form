import 'package:equatable/equatable.dart';

sealed class FormConfigEvent extends Equatable {
  const FormConfigEvent();

  @override
  List<Object?> get props => [];
}

final class LoadFormConfig extends FormConfigEvent {
  const LoadFormConfig();
}
