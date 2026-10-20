import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:json_form/core/injection/dependency_injection.dart';
import 'package:json_form/core/routes/app_routes.dart';
import 'package:json_form/domain/entities/form_config_entity.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:json_form/presentation/bloc/form_config/form_config_bloc.dart';
import 'package:json_form/presentation/bloc/form_config/form_config_event.dart';
import 'package:json_form/presentation/bloc/form_config/form_config_state.dart';
import 'package:json_form/presentation/widgets/dynamic_form.dart';

class EmployeeRegistrationPage extends StatelessWidget {
  const EmployeeRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FormConfigBloc>()..add(const LoadFormConfig()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Employee Registration')),
        body: BlocBuilder<FormConfigBloc, FormConfigState>(
          builder: (context, state) => switch (state) {
            FormConfigInitial() || FormConfigLoading() =>
              const Center(child: CircularProgressIndicator()),
            FormConfigError(:final message) => _ConfigurationError(
                message: message,
                onRetry: () => context
                    .read<FormConfigBloc>()
                    .add(const LoadFormConfig()),
              ),
            FormConfigLoaded(:final config) => _LoadedForm(config: config),
          },
        ),
      ),
    );
  }
}

class _LoadedForm extends StatelessWidget {
  const _LoadedForm({required this.config});

  final FormConfigEntity config;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DynamicFormBloc>()
        ..add(FormInitialized(config)),
      child: BlocListener<DynamicFormBloc, DynamicFormState>(
        listenWhen: (previous, current) =>
            previous.status != FormSubmissionStatus.success &&
            current.status == FormSubmissionStatus.success,
        listener: (context, state) {
          final submission = state.submission;
          if (submission != null) {
            Navigator.of(context).pushNamed(
              AppRoutes.submissionResult,
              arguments: submission,
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    config.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  DynamicForm(config: config),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfigurationError extends StatelessWidget {
  const _ConfigurationError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
