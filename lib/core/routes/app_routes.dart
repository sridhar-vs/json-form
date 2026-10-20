import 'package:flutter/material.dart';
import 'package:json_form/domain/entities/form_submission_entity.dart';
import 'package:json_form/presentation/pages/employee_registration_page.dart';
import 'package:json_form/presentation/pages/submission_result_page.dart';

abstract final class AppRoutes {
  static const employeeRegistration = '/';
  static const submissionResult = '/submission-result';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case employeeRegistration:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const EmployeeRegistrationPage(),
        );
      case submissionResult:
        final submission = settings.arguments;
        if (submission is! FormSubmissionEntity) {
          throw ArgumentError.value(
            submission,
            'settings.arguments',
            'Expected a FormSubmissionEntity.',
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => SubmissionResultPage(submission: submission),
        );
      default:
        throw ArgumentError.value(settings.name, 'settings.name', 'Unknown route.');
    }
  }
}
