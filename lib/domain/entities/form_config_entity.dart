import 'package:equatable/equatable.dart';
import 'package:json_form/domain/entities/field_config_entity.dart';

class FormConfigEntity extends Equatable {
  const FormConfigEntity({
    required this.title,
    required this.submitButton,
    required this.fields,
  });

  final String title;
  final String submitButton;
  final List<FieldConfigEntity> fields;

  @override
  List<Object?> get props => [title, submitButton, fields];
}
