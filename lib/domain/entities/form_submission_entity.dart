import 'package:equatable/equatable.dart';

class FileMetadata extends Equatable {
  const FileMetadata({
    required this.name,
    required this.extension,
    required this.sizeBytes,
    required this.path,
    required this.isImage,
  });

  final String name;
  final String extension;
  final int? sizeBytes;
  final String? path;
  final bool isImage;

  Map<String, Object?> toJson() => {
        'name': name,
        'extension': extension,
        'sizeBytes': sizeBytes,
        'status': 'selected_not_uploaded',
      };

  @override
  List<Object?> get props => [name, extension, sizeBytes, path, isImage];
}

class FormSubmissionEntity extends Equatable {
  FormSubmissionEntity(Map<String, Object?> values)
      : values = Map.unmodifiable(values);

  final Map<String, Object?> values;

  @override
  List<Object?> get props => [values];
}
