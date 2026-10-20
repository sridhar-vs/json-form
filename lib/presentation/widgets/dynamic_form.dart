import 'package:flutter/material.dart' hide FormFieldBuilder;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:json_form/domain/entities/form_config_entity.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:json_form/presentation/widgets/form_field_builder.dart';

class DynamicForm extends StatelessWidget {
  const DynamicForm({required this.config, super.key});

  final FormConfigEntity config;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final field in config.fields)
          FormFieldBuilder(key: ValueKey(field.id), field: field),
        BlocBuilder<DynamicFormBloc, DynamicFormState>(
          buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) => FilledButton(
            onPressed: state.status == FormSubmissionStatus.submitting
                ? null
                : () => context.read<DynamicFormBloc>().add(
                      const FormSubmitted(),
                    ),
            child: state.status == FormSubmissionStatus.submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(config.submitButton),
          ),
        ),
      ],
    );
  }
}
