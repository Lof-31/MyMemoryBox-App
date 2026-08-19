import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/flashcard.dart';

class CreateCardScreen extends StatefulWidget {
  const CreateCardScreen({super.key});

  @override
  State<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _frontController = TextEditingController();
  final _backController = TextEditingController();

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newCard = Flashcard.create(
      id: const Uuid().v4(),
      frontText: _frontController.text.trim(),
      backText: _backController.text.trim(),
    );

    Navigator.of(context).pop(newCard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Flashcard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _frontController,
                decoration: const InputDecoration(
                  labelText: 'Front (Question / Prompt)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the front text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _backController,
                decoration: const InputDecoration(
                  labelText: 'Back (Answer / Translation)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the back text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Save Card'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}