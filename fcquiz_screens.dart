import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/flashcard_service.dart';

class FlashcardQuizScreen extends StatefulWidget {
  final String fileName;
  const FlashcardQuizScreen({
    required this.fileName,
    super.key,
    required fileTitle,
  });

  @override
  State<FlashcardQuizScreen> createState() => _FlashcardQuizScreenState();
}

class _FlashcardQuizScreenState extends State<FlashcardQuizScreen> {
  List<Map<String, String>> _flashcards = [];
  List<String> _userAnswers = [];
  int _currentIndex = 0;
  bool _quizFinished = false;
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
    _playSound();
  }

  Future<void> _loadFlashcards() async {
    final cards = await FlashcardService.loadFlashcards(widget.fileName);
    setState(() {
      _flashcards = cards;
      _userAnswers = List.generate(cards.length, (index) => '');
    });
  }

  Future<void> _playSound() async {
    await _audioPlayer.play(AssetSource('sounds/white_noise.mp3'), volume: 0.3);
  }

  Future<void> _stopSound() async {
    await _audioPlayer.stop();
  }

  void _finishQuiz() {
    _stopSound();
    setState(() {
      _quizFinished = true;
    });
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('End Quiz?'),
            content: const Text('Your progress will be lost. Are you sure?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _stopSound();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('End'),
              ),
            ],
          ),
    );
  }

  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < _flashcards.length; i++) {
      if (_flashcards[i]['subject']!.toLowerCase().trim() ==
          _userAnswers[i].toLowerCase().trim()) {
        score++;
      }
    }
    return score;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_flashcards.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_quizFinished) {
      final score = _calculateScore();
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('End', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _flashcards.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text(
                'Your score: $score/${_flashcards.length}',
                style: const TextStyle(fontSize: 24, color: Colors.white),
                textAlign: TextAlign.center,
              );
            }

            final flashcard = _flashcards[index - 1];
            final userAnswer = _userAnswers[index - 1];
            final correct =
                userAnswer.toLowerCase().trim() ==
                flashcard['subject']!.toLowerCase().trim();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      flashcard['definition']!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Your answer: $userAnswer',
                      style: TextStyle(
                        color: correct ? Colors.green : Colors.white,
                      ),
                    ),
                  ),
                  if (!correct)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Answer: ${flashcard['subject']!}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );
    }

    final flashcard = _flashcards[_currentIndex];
    _controller.text = _userAnswers[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _confirmExit,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.volume_up), onPressed: _playSound),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_currentIndex + 1}/${_flashcards.length}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                flashcard['definition']!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) => _userAnswers[_currentIndex] = val,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex--;
                      });
                    },
                    child: const Text('Back'),
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentIndex == _flashcards.length - 1) {
                      _finishQuiz();
                    } else {
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text('Finish Quiz?'),
                              content: const Text(
                                'Are you sure you want to finish early?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _finishQuiz();
                                  },
                                  child: const Text('Finish'),
                                ),
                              ],
                            ),
                      );
                    }
                  },
                  child: Text(
                    _currentIndex == _flashcards.length - 1 ? 'Finish' : 'Next',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
