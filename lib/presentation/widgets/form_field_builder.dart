import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:json_form/domain/entities/field_config_entity.dart';
import 'package:json_form/domain/entities/form_submission_entity.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:json_form/presentation/bloc/dynamic_form/dynamic_form_state.dart';

class FormFieldBuilder extends StatelessWidget {
  const FormFieldBuilder({required this.field, super.key});

  final FieldConfigEntity field;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DynamicFormBloc, DynamicFormState>(
      buildWhen: (previous, current) =>
          previous.values[field.id] != current.values[field.id] ||
          previous.visibility[field.id] != current.visibility[field.id] ||
          previous.errors[field.id] != current.errors[field.id] ||
          previous.availableOptions[field.id] !=
              current.availableOptions[field.id],
      builder: (context, state) {
        if (state.visibility[field.id] == false) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildField(context, state),
        );
      },
    );
  }

  Widget _buildField(BuildContext context, DynamicFormState state) {
    final value = state.values[field.id];
    final error = state.errors[field.id];
    final label = field.required ? '${field.label} *' : field.label;
    final bloc = context.read<DynamicFormBloc>();

    switch (field.type) {
      case 'text':
      case 'email':
      case 'phone':
      case 'password':
      case 'number':
      case 'textarea':
        final keyboardType = switch (field.type) {
          'email' => TextInputType.emailAddress,
          'phone' => TextInputType.phone,
          'number' => const TextInputType.numberWithOptions(decimal: true),
          'textarea' => TextInputType.multiline,
          _ => TextInputType.text,
        };
        return TextFormField(
          key: ValueKey('field-${field.id}'),
          initialValue: value is String ? value : null,
          obscureText: field.type == 'password',
          keyboardType: keyboardType,
          maxLength: field.maxLength,
          maxLines: field.type == 'textarea' ? 4 : 1,
          decoration: InputDecoration(
            labelText: label,
            hintText: field.placeholder,
            errorText: error,
            counterText: '',
          ),
          onChanged: (next) => bloc.add(FieldValueChanged(field.id, next)),
        );
      case 'dropdown':
        final options = state.availableOptions[field.id] ?? const [];
        final selected = value is String && options.contains(value)
            ? value
            : null;
        return DropdownButtonFormField<String>(
          key: ValueKey('field-${field.id}'),
          initialValue: selected,
          decoration: InputDecoration(labelText: label, errorText: error),
          hint: Text(
            field.dependsOn == null
                ? 'Select an option'
                : 'Select ${field.label.toLowerCase()}',
          ),
          items: options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          onChanged: options.isEmpty
              ? null
              : (next) => bloc.add(FieldValueChanged(field.id, next)),
        );
      case 'radio':
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            errorText: error,
            border: InputBorder.none,
          ),
          child: RadioGroup<String>(
            groupValue: value is String ? value : null,
            onChanged: (next) => bloc.add(FieldValueChanged(field.id, next)),
            child: Column(
              children: [
                for (final option in field.options)
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option),
                    value: option,
                  ),
              ],
            ),
          ),
        );
      case 'checkbox':
        final selected = value is List
            ? value.whereType<String>().toSet()
            : <String>{};
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            errorText: error,
            border: InputBorder.none,
          ),
          child: Column(
            children: [
              for (final option in field.options)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(option),
                  value: selected.contains(option),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (checked) {
                    final next = Set<String>.of(selected);
                    if (checked == true) {
                      next.add(option);
                    } else {
                      next.remove(option);
                    }
                    bloc.add(FieldValueChanged(field.id, next.toList()));
                  },
                ),
            ],
          ),
        );
      case 'checkbox_single':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(label),
              value: value == true,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (next) =>
                  bloc.add(FieldValueChanged(field.id, next == true)),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        );
      case 'switch':
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          value: value == true,
          onChanged: (next) => bloc.add(FieldValueChanged(field.id, next)),
        );
      case 'slider':
        final min = (field.min ?? 0).toDouble();
        final max = (field.max ?? 100).toDouble();
        final selected = value is num ? value.toDouble().clamp(min, max) : min;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label: ${selected.toStringAsFixed(0)}'),
            Slider(
              value: selected,
              min: min,
              max: max,
              divisions: field.divisions,
              label: selected.toStringAsFixed(0),
              onChanged: (next) => bloc.add(FieldValueChanged(field.id, next)),
            ),
            if (error != null)
              Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        );
      case 'date':
        return _selectionButton(
          context,
          label: label,
          value: value is String ? value : null,
          error: error,
          onPressed: () async {
            final initialDate = value is String
                ? DateTime.tryParse(value) ?? DateTime.now()
                : DateTime.now();
            final date = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (date != null && context.mounted) {
              bloc.add(
                FieldValueChanged(
                  field.id,
                  '${date.year.toString().padLeft(4, '0')}-'
                  '${date.month.toString().padLeft(2, '0')}-'
                  '${date.day.toString().padLeft(2, '0')}',
                ),
              );
            }
          },
        );
      case 'time':
        return _selectionButton(
          context,
          label: label,
          value: value is String ? value : null,
          error: error,
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 9, minute: 0),
            );
            if (time != null && context.mounted) {
              bloc.add(
                FieldValueChanged(
                  field.id,
                  '${time.hour.toString().padLeft(2, '0')}:'
                  '${time.minute.toString().padLeft(2, '0')}',
                ),
              );
            }
          },
        );
      case 'file':
        return _fileSelector(context, value, error, bloc);
      case 'image':
        return _imageSelector(context, value, error, bloc);
      default:
        return InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: const Text('This field type is not supported.'),
        );
    }
  }

  Widget _selectionButton(
    BuildContext context, {
    required String label,
    required String? value,
    required String? error,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.event),
          label: Text(value == null ? label : '$label: $value'),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }

  Widget _fileSelector(
    BuildContext context,
    Object? value,
    String? error,
    DynamicFormBloc bloc,
  ) {
    final selected = value is FileMetadata ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            try {
              final file = await FilePicker.pickFile(
                type: field.allowedExtensions.isEmpty
                    ? FileType.any
                    : FileType.custom,
                allowedExtensions: field.allowedExtensions.isEmpty
                    ? null
                    : field.allowedExtensions,
              );
              if (file == null) return;
              final extension = (file.extension ?? '').toLowerCase();
              if (field.allowedExtensions.isNotEmpty &&
                  !field.allowedExtensions
                      .map((allowed) => allowed.toLowerCase())
                      .contains(extension)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('That file type is not allowed.'),
                    ),
                  );
                }
                return;
              }
              final sizeBytes = await file.length();
              bloc.add(
                FieldValueChanged(
                  field.id,
                  FileMetadata(
                    name: file.name,
                    extension: extension,
                    sizeBytes: sizeBytes,
                    path: file.path,
                    isImage: false,
                  ),
                ),
              );
            } on Exception catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not select file: $error')),
                );
              }
            }
          },
          icon: const Icon(Icons.attach_file),
          label: Text(
            selected?.name ?? '${field.label}${field.required ? ' *' : ''}',
          ),
        ),
        if (error != null)
          Text(
            error,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }

  Widget _imageSelector(
    BuildContext context,
    Object? value,
    String? error,
    DynamicFormBloc bloc,
  ) {
    final selected = value is FileMetadata ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            try {
              final image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );
              if (image == null) return;
              final bytes = await image.length();
              if (!context.mounted) return;
              bloc.add(
                FieldValueChanged(
                  field.id,
                  FileMetadata(
                    name: image.name,
                    extension: image.name.contains('.')
                        ? image.name.split('.').last.toLowerCase()
                        : '',
                    sizeBytes: bytes,
                    path: image.path,
                    isImage: true,
                  ),
                ),
              );
            } on Exception catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not select image: $error')),
                );
              }
            }
          },
          icon: const Icon(Icons.image_outlined),
          label: Text(selected?.name ?? field.label),
        ),
        if (error != null)
          Text(
            error,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}
