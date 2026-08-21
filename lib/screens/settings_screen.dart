import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(int index)? onThemeChanged;
  final VoidCallback? onDataReset;

  const SettingsScreen({
    super.key,
    this.onThemeChanged,
    this.onDataReset,
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

  final List<Color> _colorPalette = [
    Colors.indigo,
    Colors.teal,
    Colors.deepPurple,
    Colors.blueGrey,
    Colors.amber.shade800,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final time = await _storageService.getReminderTime();
    final colorIndex = await _storageService.getThemeColorIndex();
    setState(() {
      _reminderTime = time;
      _selectedColorIndex = colorIndex;
      _isLoading = false;
    });
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      await _storageService.saveReminderTime(picked);
      final cards = await _storageService.loadCards();
      await _notificationService.syncDailyReminder(cards);
    }
  }

  Future<void> _changeTheme(int index) async {
    setState(() {
      _selectedColorIndex = index;
    });
    await _storageService.saveThemeColorIndex(index);
    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!(index);
    }
  }

  Future<void> _confirmResetData() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Reset All Data?'),
          content: const Text(
            'This will permanently delete all flashcards, review histories, settings, and streak progress. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Reset Everything'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _storageService.clearAllData();
      await _notificationService.cancelAllNotifications();
      await _loadSettings();
      if (widget.onDataReset != null) {
        widget.onDataReset!();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data has been wiped.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
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
                    'Theme Accent Color',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_colorPalette.length, (index) {
                      final color = _colorPalette[index];
                      final isSelected = _selectedColorIndex == index;
                      return GestureDetector(
                        onTap: () => _changeTheme(index),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 20, color: Colors.white)
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
            'Danger Zone',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.delete_forever_outlined, color: Colors.red.shade700),
              title: const Text(
                'Delete All Data',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Reset flashcards, streak and preferences'),
              trailing: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                onPressed: _confirmResetData,
                child: const Text('Reset'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}