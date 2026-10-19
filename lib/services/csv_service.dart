import 'package:uuid/uuid.dart';
import '../models/flashcard.dart';

class CsvImportResult {
  final List<Flashcard> cards;
  final int invalidRows;

  CsvImportResult(this.cards, this.invalidRows);
}

class CsvService {
  static const List<String> _columns = [
    'front',
    'back',
    'level',
    'next_review_date',
    'reversed',
  ];

  String encode(List<Flashcard> cards) {
    final buffer = StringBuffer()..writeln(_columns.join(','));
    for (final c in cards) {
      buffer.writeln([
        _escape(c.frontText),
        _escape(c.backText),
        '${c.level}',
        _formatDate(c.nextReviewDate),
        '${c.isReversed}',
      ].join(','));
    }
    return buffer.toString();
  }

  CsvImportResult parse(String content) {
    if (content.startsWith('﻿')) content = content.substring(1);

    final firstLine = content.split('\n').first;
    final rows = _parseRows(content, _detectDelimiter(firstLine))
        .where((r) => r.any((cell) => cell.trim().isNotEmpty))
        .toList();
    if (rows.isEmpty) return CsvImportResult([], 0);

    final header = rows.first.map((h) => h.trim().toLowerCase()).toList();
    final bool hasHeader = header.contains('front') && header.contains('back');
    final Map<String, int> index = {
      for (var i = 0; i < _columns.length; i++)
        _columns[i]: hasHeader ? header.indexOf(_columns[i]) : i,
    };

    final cards = <Flashcard>[];
    int invalid = 0;
    final today = _today();

    for (final row in rows.skip(hasHeader ? 1 : 0)) {
      String cell(String name) {
        final i = index[name]!;
        return i >= 0 && i < row.length ? row[i].trim() : '';
      }

      final front = cell('front');
      final back = cell('back');
      final level = cell('level').isEmpty ? 0 : int.tryParse(cell('level'));
      final date = cell('next_review_date').isEmpty
          ? DateTime(today.year, today.month, today.day + 1)
          : _parseDate(cell('next_review_date'));
      final reversedText = cell('reversed').toLowerCase();

      if (front.isEmpty ||
          back.isEmpty ||
          level == null ||
          level < 0 ||
          level > 8 ||
          date == null) {
        invalid++;
        continue;
      }

      cards.add(Flashcard(
        id: const Uuid().v4(),
        frontText: front,
        backText: back,
        level: level,
        nextReviewDate: date,
        isReversed: reversedText == 'true' || reversedText == '1',
      ));
    }

    return CsvImportResult(cards, invalid);
  }

  String _detectDelimiter(String headerLine) {
    final candidates = [',', ';', '\t'];
    candidates.sort((a, b) =>
        b.allMatches(headerLine).length.compareTo(a.allMatches(headerLine).length));
    return candidates.first;
  }

  List<List<String>> _parseRows(String content, String delimiter) {
    final rows = <List<String>>[];
    var row = <String>[];
    final cell = StringBuffer();
    bool inQuotes = false;

    for (var i = 0; i < content.length; i++) {
      final ch = content[i];
      if (inQuotes) {
        if (ch == '"') {
          if (i + 1 < content.length && content[i + 1] == '"') {
            cell.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          cell.write(ch);
        }
      } else if (ch == '"') {
        inQuotes = true;
      } else if (ch == delimiter) {
        row.add(cell.toString());
        cell.clear();
      } else if (ch == '\n' || ch == '\r') {
        if (ch == '\r' && i + 1 < content.length && content[i + 1] == '\n') i++;
        row.add(cell.toString());
        cell.clear();
        rows.add(row);
        row = <String>[];
      } else {
        cell.write(ch);
      }
    }
    if (cell.isNotEmpty || row.isNotEmpty) {
      row.add(cell.toString());
      rows.add(row);
    }
    return rows;
  }

  String _escape(String value) {
    if (value.contains(RegExp(r'[",;\n\r\t]'))) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  DateTime? _parseDate(String value) {
    final fr = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(value);
    final parsed = fr != null
        ? DateTime(int.parse(fr[3]!), int.parse(fr[2]!), int.parse(fr[1]!))
        : DateTime.tryParse(value);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
