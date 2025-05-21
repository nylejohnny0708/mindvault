import 'package:flutter/material.dart';
import 'package:mindvault/services/storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class NotesScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialContent;

  const NotesScreen({Key? key, this.initialTitle, this.initialContent})
    : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late bool isNewFile;
  String? existingFileName;

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null && widget.initialContent != null) {
      _titleController.text = widget.initialTitle!;
      _contentController.text = widget.initialContent!;
      isNewFile = false;
      existingFileName = widget.initialTitle!;
    } else {
      isNewFile = true;
    }
  }

  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    print('Trying to save...');
    print('Title: $title');
    print(
      'Content: ${content.substring(0, content.length > 30 ? 30 : content.length)}...',
    );

    if (title.isEmpty) {
      _showAlert('Missing Title', 'Please enter a title before saving.');
      print('❌ Title is empty');
      return;
    }

    final alreadyExists = await doesFileExist(title);
    print('File already exists? $alreadyExists');
    print('isNewFile: $isNewFile');
    print('existingFileName: $existingFileName');

    if (isNewFile && alreadyExists) {
      _showAlert('Duplicate Title', 'A note with this title already exists.');
      print('❌ Duplicate file, aborting save.');
      return;
    }

    if (!isNewFile && existingFileName != null && existingFileName != title) {
      print('Renamed file. Deleting old file: $existingFileName');
      await StorageService.deleteFile(existingFileName!);
    }

    try {
      print('Calling StorageService.saveFile...');
      await StorageService.saveFile(title, content);
      print('✅ Save successful.');
      Navigator.pop(context, title);
    } catch (e) {
      print('❌ Save failed: $e');
      _showAlert('Error', 'Failed to save note: $e');
    }
  }

  Future<bool> doesFileExist(String title) async {
    final path =
        await StorageService.getLocalPath(); // You might need to make _getLocalPath public
    final file = File('$path/$title.txt');
    return file.exists();
  }

  Future<void> _handleBack() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final shouldSave = await _showConfirmationDialog(
      title: 'Save Changes?',
      content: 'Do you want to save your changes before going back?',
    );

    if (shouldSave == true) {
      await saveNote();
    } else {
      Navigator.pop(context);
    }
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
    );
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handleBack();
        return false; // Prevent default back action
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo and Title field
                Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'MindVault',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 8, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Title...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Notes Text Entry Box
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText:
                            'Type your notes here. Writing a word and writing its definition with a “-” in between the two will automatically turn the sentence into a flashcard.',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleBack,
                        child: const Text('Back'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: saveNote,
                        child: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
