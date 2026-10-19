import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/flashcard.dart';
import '../services/csv_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final List<Flashcard> cards;
  final Function(int index)? onThemeChanged;
  final Function(ThemeMode mode)? onThemeModeChanged;
  final Future<int> Function(List<Flashcard> cards) onImport;
  final VoidCallback? onDataReset;

  const SettingsScreen({
    super.key,
    required this.cards,
    required this.onImport,
    this.onThemeChanged,
    this.onThemeModeChanged,
    this.onDataReset,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();

  int _selectedColorIndex = 0;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final colorIndex = await _storageService.getThemeColorIndex();
    final themeMode = await _storageService.getThemeMode();
    setState(() {
      _themeMode = themeMode;
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

  Future<void> _changeThemeMode(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });
    await _storageService.saveThemeMode(mode);
    widget.onThemeModeChanged?.call(mode);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _exportCards() async {
    final csv = CsvService().encode(widget.cards);
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    try {
      final saved = await FilePicker.saveFile(
        dialogTitle: 'Export cards',
        fileName: 'my_memory_box_$date.csv',
        bytes: utf8.encode('\uFEFF$csv'),
        mimeType: 'text/csv',
      );
      if (saved != null) {
        final count = widget.cards.length;
        _showMessage('$count card${count > 1 ? 's' : ''} exported.');
      }
    } catch (e) {
      debugPrint('Error exporting cards: $e');
      _showMessage('Export failed.');
    }
  }

  Future<void> _importCardsFromFile() async {
    try {
      final file = await FilePicker.pickFile(type: FileType.any);
      if (file == null) return;

      final content = utf8.decode(await file.readAsBytes(), allowMalformed: true);
      final result = CsvService().parse(content);
      if (result.cards.isEmpty) {
        _showMessage(result.invalidRows > 0
            ? 'No valid cards found (${result.invalidRows} invalid rows).'
            : 'No cards found in this file.');
        return;
      }

      final added = await widget.onImport(result.cards);
      final skipped = result.cards.length - added;
      _showMessage([
        '$added card${added > 1 ? 's' : ''} imported',
        if (skipped > 0) '$skipped duplicate${skipped > 1 ? 's' : ''} skipped',
        if (result.invalidRows > 0)
          '${result.invalidRows} invalid row${result.invalidRows > 1 ? 's' : ''}',
      ].join(', '));
    } catch (e) {
      debugPrint('Error importing cards: $e');
      _showMessage('Import failed: the file could not be read.');
    }
  }

  Widget _sectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
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
      widget.onThemeChanged?.call(0);
      widget.onThemeModeChanged?.call(ThemeMode.system);
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
          _sectionTitle('Appearance', primaryColor),
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
                  const SizedBox(height: 20),
                  const Text(
                    'Theme',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto_outlined),
                          label: Text('System'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_outlined),
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_outlined),
                          label: Text('Dark'),
                        ),
                      ],
                      selected: {_themeMode},
                      showSelectedIcon: false,
                      onSelectionChanged: (selection) =>
                          _changeThemeMode(selection.first),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Data', primaryColor),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.file_upload_outlined, color: primaryColor),
                  title: const Text('Import cards'),
                  subtitle: const Text('Add cards from a CSV file'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _importCardsFromFile,
                ),
                Divider(height: 1, color: context.colors.outlineVariant),
                ListTile(
                  enabled: widget.cards.isNotEmpty,
                  leading: Icon(Icons.file_download_outlined, color: primaryColor),
                  title: const Text('Export cards'),
                  subtitle: Text(
                    widget.cards.length == 1
                        ? 'Save your card to a CSV file'
                        : 'Save all ${widget.cards.length} cards to a CSV file',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _exportCards,
                ),
                Divider(height: 1, color: context.colors.outlineVariant),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: context.colors.error,
                  ),
                  title: Text(
                    'Delete all data',
                    style: TextStyle(color: context.colors.error),
                  ),
                  subtitle: const Text('Reset cards, streak and preferences'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _confirmResetData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

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