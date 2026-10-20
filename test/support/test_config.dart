import 'package:json_form/data/models/form_config_model.dart';
import 'package:json_form/domain/entities/form_config_entity.dart';

FormConfigEntity testConfig() => FormConfigModel.fromJson({
  'title': 'Test employee form',
  'submitButton': 'Register',
  'fields': [
    {
      'id': 'country',
      'type': 'dropdown',
      'label': 'Country',
      'required': true,
      'options': ['India', 'USA'],
    },
    {
      'id': 'state',
      'type': 'dropdown',
      'label': 'State',
      'required': true,
      'dependsOn': 'country',
      'optionsMap': {
        'India': ['Tamil Nadu', 'Kerala'],
        'USA': ['Texas'],
      },
    },
    {'id': 'is_married', 'type': 'switch', 'label': 'Married'},
    {
      'id': 'spouse_name',
      'type': 'text',
      'label': 'Spouse Name',
      'required': true,
      'visibleIf': {'field': 'is_married', 'equals': true},
    },
    {
      'id': 'password',
      'type': 'password',
      'label': 'Password',
      'required': true,
      'minLength': 8,
    },
    {
      'id': 'accept_terms',
      'type': 'checkbox_single',
      'label': 'I accept the Terms & Conditions',
      'required': true,
    },
  ],
}).toEntity();
