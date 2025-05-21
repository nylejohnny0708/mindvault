import 'dart:io';
import 'storage_service.dart';

class FlashcardService {
  // Get the path for flashcard files
  static Future<File> _getFlashcardFile(String fileName) async {
    final path = await StorageService.getLocalPath();
    return File('$path/flashcards_$fileName.txt');
  }

  // Extract and save flashcards from a note
  static Future<void> generateFlashcards(String fileName) async {
    try {
      final noteContent = await StorageService.readFile(fileName);
      final paragraphs = noteContent.split('\n\n');
      List<Map<String, String>> flashcards = [];

      for (var para in paragraphs) {
        if (para.trim().contains(' - ')) {
          var parts = para.trim().split(' - ');
          if (parts.length == 2) {
            flashcards.add({
              'subject': parts[0].trim(),
              'definition': parts[1].trim(),
            });
          }
        }
      }

      final flashcardFile = await _getFlashcardFile(fileName);

      if (flashcards.isNotEmpty) {
        final flashcardText = flashcards
            .map((f) => '${f['subject']} - ${f['definition']}')
            .join('\n\n');
        await flashcardFile.writeAsString(flashcardText);
      } else {
        // Delete flashcard file if no valid flashcards exist
        if (await flashcardFile.exists()) {
          await flashcardFile.delete();
        }
      }
    } catch (e) {
      print('Error generating flashcards: $e');
    }
  }

  // Load flashcards from a flashcard file
  static Future<List<Map<String, String>>> loadFlashcards(
    String fileName,
  ) async {
    try {
      final flashcardFile = await _getFlashcardFile(fileName);
      if (!await flashcardFile.exists()) return [];

      final content = await flashcardFile.readAsString();
      final paragraphs = content.split('\n\n');
      List<Map<String, String>> flashcards = [];

      for (var para in paragraphs) {
        if (para.trim().contains(' - ')) {
          var parts = para.trim().split(' - ');
          if (parts.length == 2) {
            flashcards.add({
              'subject': parts[0].trim(),
              'definition': parts[1].trim(),
            });
          }
        }
      }

      return flashcards;
    } catch (e) {
      print('Error loading flashcards: $e');
      return [];
    }
  }

  // Delete associated flashcard file (optional use)
  static Future<void> deleteFlashcards(String fileName) async {
    final flashcardFile = await _getFlashcardFile(fileName);
    if (await flashcardFile.exists()) {
      await flashcardFile.delete();
    }
  }
}
