import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_form/data/models/form_config_model.dart';
import 'package:json_form/domain/usecases/submit_form.dart';
import 'package:json_form/domain/usecases/validate_form.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:json_form/presentation/widgets/dynamic_form.dart';

void main() {
  testWidgets('renders configured fields and omits initially hidden fields', (
    tester,
  ) async {
    final fields = <Map<String, dynamic>>[
      {
        'id': 'country',
        'type': 'dropdown',
        'label': 'Country',
        'required': true,
        'options': ['India', 'USA'],
      },
      {'id': 'is_married', 'type': 'switch', 'label': 'Married'},
      {
        'id': 'spouse_name',
        'type': 'text',
        'label': 'Spouse Name',
        'required': true,
        'visibleIf': {'field': 'is_married', 'equals': true},
      },
    ];
    fields[0]['label'] = 'Work Country';
    fields.add({
      'id': 'additional',
      'type': 'custom_future_type',
      'label': 'Additional Field',
    });
    final config = FormConfigModel.fromJson({
      'title': 'Test form',
      'submitButton': 'Register',
      'fields': fields,
    }).toEntity();
    final bloc = DynamicFormBloc(
      validateForm: ValidateForm(),
      submitForm: SubmitForm(),
    )..add(FormInitialized(config));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (_) => bloc,
            child: SingleChildScrollView(child: DynamicForm(config: config)),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Work Country *'), findsOneWidget);
    expect(find.text('Spouse Name *'), findsNothing);
    expect(find.text('Married'), findsOneWidget);
    expect(find.text('Additional Field'), findsOneWidget);
    expect(find.text('This field type is not supported.'), findsOneWidget);
  });
}
