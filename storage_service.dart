import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  // Get local storage path
  static Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Create a File object for a note
  static Future<File> _getNoteFile(String fileName) async {
    final path = await getLocalPath();
    return File('$path/$fileName.txt');
  }

  // Save content to a file
  static Future<void> saveFile(String fileName, String content) async {
    final file = await _getNoteFile(fileName);
    await file.writeAsString(content);
  }

  // Read content from a file
  static Future<String> readFile(String fileName) async {
    final file = await _getNoteFile(fileName);
    if (await file.exists()) {
      return await file.readAsString();
    } else {
      throw Exception('File not found: $fileName');
    }
  }

  // Delete a file
  static Future<void> deleteFile(String fileName) async {
    final file = await _getNoteFile(fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // List all note files
  static Future<List<String>> listNoteFiles() async {
    final path = await getLocalPath();
    final directory = Directory(path);
    final files = directory.listSync();

    return files
        .where(
          (file) =>
              file is File &&
              file.path.endsWith('.txt') &&
              !file.path.contains('flashcards_'),
        )
        .map((file) => file.uri.pathSegments.last.replaceAll('.txt', ''))
        .toList();
  }

  // Check if a note file exists
  static Future<bool> fileExists(String fileName) async {
    final file = await _getNoteFile(fileName);
    return file.exists();
  }
}
