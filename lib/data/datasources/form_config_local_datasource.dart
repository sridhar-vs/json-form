import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:json_form/core/error/exceptions.dart';
import 'package:json_form/data/models/form_config_model.dart';

class FormConfigLocalDataSource {
  const FormConfigLocalDataSource(this.assetBundle);

  final AssetBundle assetBundle;
  static const assetPath = 'assets/form_config.json';

  Future<FormConfigModel> loadConfig() async {
    try {
      final source = await assetBundle.loadString(assetPath);
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, dynamic>) {
        throw const FormConfigurationException(
          'The form configuration must be a JSON object.',
        );
      }
      return FormConfigModel.fromJson(decoded);
    } on FlutterError {
      throw const FormConfigurationException(
        'The form configuration asset could not be loaded.',
      );
    } on FormatException {
      throw const FormConfigurationException(
        'The form configuration contains invalid JSON.',
      );
    }
  }
}
