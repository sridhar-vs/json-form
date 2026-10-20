class FormConfigurationException implements Exception {
  const FormConfigurationException(this.message);

  final String message;

  @override
  String toString() => message;
}
