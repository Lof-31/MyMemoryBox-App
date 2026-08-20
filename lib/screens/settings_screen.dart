import 'package:flutter/material.dart';
import '../main.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(int index)? onThemeChanged;

  const SettingsScreen({
    super.key,
    this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  int _selectedColorIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final time = await _storageService.getReminderTime();
    final colorIdx = await _storageService.getThemeColorIndex();
    setState(() {
      _reminderTime = time;
      _selectedColorIndex = (colorIdx >= 0 && colorIdx < appThemeColors.length) ? colorIdx : 0;
      _isLoading = false;
    });
  }

  Future<void> _changeThemeColor(int index) async {
    setState(() {
      _selectedColorIndex = index;
    });
    await _storageService.saveThemeColorIndex(index);
    widget.onThemeChanged?.call(index);
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
            content: Text('Reminder time set to ${picked.format(context)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme Color',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select your favorite primary accent color',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(appThemeColors.length, (index) {
                      final color = appThemeColors[index];
                      final isSelected = _selectedColorIndex == index;

                      return GestureDetector(
                        onTap: () => _changeThemeColor(index),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          )
                              : null,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.alarm, color: primaryColor),
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
          Text(
            'About',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.info_outline, color: primaryColor),
              title: const Text('My Memory Box'),
              subtitle: const Text('Version 1.0.0 • Spaced Repetition System'),
            ),
          ),
        ],
      ),
    );
  }
}