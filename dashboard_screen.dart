import 'package:flutter/material.dart';
import 'package:mindvault/services/storage_service.dart';
import 'notes_screen.dart';
import 'fcmenu_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> allNotes = [];

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await StorageService.listNoteFiles();
    setState(() {
      allNotes = notes;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    List<String> filteredNotes =
        allNotes
            .where(
              (note) => note.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            children: [
              // Top bar with centered app name and settings icon
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        'mindvault.',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          // TODO: Open settings screen
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotesScreen(),
                            ),
                          );

                          // Refresh dashboard if a note was saved
                          if (result != null && result.isNotEmpty) {
                            await _loadNotes();
                          }
                        },
                        icon: Icon(Icons.note_add, color: Colors.greenAccent),
                        label: Text('New Notes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white12,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FlashcardsScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.style, color: Colors.pinkAccent),
                        label: Text('Flashcards'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white12,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Container(width: 95, height: 1, color: Colors.white30),

              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),

              // Notes List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.white10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.description,
                          color: Colors.greenAccent,
                        ),
                        title: Text(filteredNotes[index]),
                        onTap: () async {
                          final content = await StorageService.readFile(
                            filteredNotes[index],
                          );
                          final result = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => NotesScreen(
                                    initialTitle: filteredNotes[index],
                                    initialContent: content,
                                  ),
                            ),
                          );

                          if (result != null && result.isNotEmpty) {
                            await _loadNotes();
                          }
                        },
                      ),
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
