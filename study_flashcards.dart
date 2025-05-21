import 'package:flutter/material.dart';
import 'package:mindvault/services/flashcard_service.dart'; // Make sure this path is correct

class StudyFlashcards extends StatefulWidget {
  final String fileTitle; // e.g., "General Chemistry"

  const StudyFlashcards({Key? key, required this.fileTitle}) : super(key: key);

  @override
  State<StudyFlashcards> createState() => _StudyFlashcardsState();
}

class _StudyFlashcardsState extends State<StudyFlashcards> {
  List<Map<String, String>> flashcards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    final cards = await FlashcardService.loadFlashcards(widget.fileTitle);
    setState(() {
      flashcards = cards;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),

                      // File title
                      Text(
                        widget.fileTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),
                      const Divider(color: Colors.white, thickness: 1),
                      const SizedBox(height: 16),

                      // Flashcards list
                      Expanded(
                        child: ListView.builder(
                          itemCount: flashcards.length,
                          itemBuilder: (context, index) {
                            final card = flashcards[index];
                            return _Flashcard(
                              definition: card['definition'] ?? '',
                              subject: card['subject'] ?? '',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

class _Flashcard extends StatelessWidget {
  final String subject;
  final String definition;

  const _Flashcard({Key? key, required this.subject, required this.definition})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              definition,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              subject,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
