import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/fcmenu_screen.dart';
import 'screens/study_flashcards.dart';
import 'screens/fcquiz_screens.dart';

void main() {
  runApp(MindVaultApp());
}

class MindVaultApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mindvault.',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        // Add other theme customizations here if needed
      ),
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(), // Start with Dashboard
      // All app routes
      routes: {
        '/notes': (context) => NotesScreen(),
        '/flashcards': (context) => FlashcardsScreen(),
      },

      // Use `onGenerateRoute` for screens needing arguments
      onGenerateRoute: (settings) {
        if (settings.name == '/study') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => StudyFlashcards(fileTitle: args['fileTitle']),
          );
        } else if (settings.name == '/quiz') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (_) => FlashcardQuizScreen(
                  fileTitle: args['fileTitle'],
                  fileName: '',
                ),
          );
        }
        return null; // Unknown route
      },
    );
  }
}
