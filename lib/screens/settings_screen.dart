import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final time = await _storageService.getReminderTime();
    setState(() {
      _reminderTime = time;
      _isLoading = false;
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });

      await _storageService.saveReminderTime(picked);
      final cards = await _storageService.loadCards();
      await _notificationService.syncDailyReminder(cards, customTime: picked);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reminder time set to ${picked.format(context)}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.alarm, color: Colors.indigo),
              title: const Text('Daily Reminder Time'),
              subtitle: const Text('Choose when to be reminded for reviews'),
              trailing: FilledButton.tonal(
                onPressed: _selectTime,
                child: Text(
                  _reminderTime.format(context),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'About',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const ListTile(
              leading: Icon(Icons.info_outline, color: Colors.indigo),
              title: Text('My Memory Box'),
              subtitle: Text('Version 1.0.0 • Spaced Repetition System'),
            ),
          ),
        ],
      ),
    );
  }
}