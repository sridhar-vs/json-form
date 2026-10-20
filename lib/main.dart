import 'package:flutter/material.dart';
import 'package:json_form/core/injection/dependency_injection.dart';
import 'package:json_form/core/routes/app_routes.dart';
import 'package:json_form/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const EmployeeDynamicFormApp());
}

class EmployeeDynamicFormApp extends StatelessWidget {
  const EmployeeDynamicFormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Registration',
      theme: AppTheme.light,
      initialRoute: AppRoutes.employeeRegistration,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
