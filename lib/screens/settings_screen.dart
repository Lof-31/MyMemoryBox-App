import 'package:flutter/material.dart';
import '../main.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

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

  int _selectedColorIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final colorIndex = await _storageService.getThemeColorIndex();
    setState(() {
      _selectedColorIndex =
      (colorIndex < appThemeColors.length) ? colorIndex : 0;
      _isLoading = false;
    });
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
    final bool? isConfirmed = await showDialog<bool>(
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
                backgroundColor: context.colors.error,
                foregroundColor: context.colors.onError,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Reset Everything'),
            ),
          ],
        );
      },
    );

    if (isConfirmed == true) {
      await _storageService.clearAllData();
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
    const double creditsFontSize = 14;

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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(appThemeColors.length, (index) {
                      final color = appThemeColors[index];
                      final isSelected = _selectedColorIndex == index;
                      final bool isLightColor =
                          ThemeData.estimateBrightnessForColor(color) ==
                              Brightness.light;

                      return GestureDetector(
                        onTap: () => _changeTheme(index),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: context.colors.onSurface, width: 3)
                                : Border.all(
                              color: context.colors.outlineVariant,
                              width: 1,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                            Icons.check,
                            size: 18,
                            color: isLightColor
                                ? Colors.black87
                                : Colors.white,
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
            'Danger Zone',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.colors.error,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: context.colors.error,
              ),
              title: const Text(
                'Delete All Data',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Reset flashcards, streak and preferences'),
              trailing: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.error,
                  foregroundColor: context.colors.onError,
                ),
                onPressed: _confirmResetData,
                child: const Text('Reset'),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // --- SECTION CRÉDITS ---
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Created with ',
                      style: TextStyle(
                        fontSize: creditsFontSize,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    Icon(
                      Icons.favorite_rounded,
                      size: creditsFontSize+1,
                      color: context.colors.error,
                    ),
                    Text(
                      ' by ',
                      style: TextStyle(
                        fontSize: creditsFontSize,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Louis FILLOUX',
                      style: TextStyle(
                        fontSize: creditsFontSize,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'My Memory Box',
                  style: TextStyle(
                    fontSize: creditsFontSize-2,
                    color: context.colors.outline,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}