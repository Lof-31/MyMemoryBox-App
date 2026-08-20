import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('My Memory Box'),
              subtitle: Text('Version 1.0.0 • Spaced Repetition (Leitner)'),
            ),
          ),
        ],
      ),
    );
  }
}