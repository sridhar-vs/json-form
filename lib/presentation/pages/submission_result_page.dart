import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_form/domain/entities/form_submission_entity.dart';

class SubmissionResultPage extends StatelessWidget {
  const SubmissionResultPage({required this.submission, super.key});

  final FormSubmissionEntity submission;

  @override
  Widget build(BuildContext context) {
    final json = const JsonEncoder.withIndent('  ').convert(submission.values);
    return Scaffold(
      appBar: AppBar(title: const Text('Registration submitted')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Your submission is ready. File selections are local metadata '
                'only and have not been uploaded.',
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    json,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to form'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
