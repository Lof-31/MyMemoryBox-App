import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';

class StorageService {
  static const String _storageKey = 'flashcards_data';

  Future<List<Flashcard>> loadCards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString(_storageKey);

    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    final List<dynamic> decodedList = jsonDecode(rawJson) as List<dynamic>;
    return decodedList
        .map((item) => Flashcard.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCards(List<Flashcard> cards) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> serialized =
    cards.map((card) => card.toMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(serialized));
  }
}