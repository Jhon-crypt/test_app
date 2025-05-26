import 'package:flutter/material.dart';
import '../models/note.dart';
import '../widgets/empty_state_illustration.dart';
import 'note_edit_screen.dart';
import 'package:intl/intl.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final List<Note> _notes = [];
  final List<Color> _noteColors = [
    const Color(0xFFFFC0FF), // Pink
    const Color(0xFFFFB5B5), // Salmon
    const Color(0xFFB8F4B8), // Green
    const Color(0xFFFFF4B5), // Yellow
    const Color(0xFFB5F4F4), // Cyan
    const Color(0xFFE0C0FF), // Purple
  ];

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  void _showSearchBar() {
    // TODO: Implement search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Search coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Notes'),
        content: const Text('A simple and beautiful notes app to capture your thoughts and memories.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getNextNoteColor() {
    if (_notes.isEmpty) return _noteColors.first;
    final lastNoteColorIndex = _noteColors.indexOf(_notes.last.color);
    return _noteColors[(lastNoteColorIndex + 1) % _noteColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, size: 24),
              onPressed: _showSearchBar,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.info_outline, size: 24),
              onPressed: _showInfo,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const EmptyStateIllustration(),
                  const SizedBox(height: 32),
                  Text(
                    'Create your first note!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _notes.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Dismissible(
                  key: Key(note.id),
                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _deleteNote(index, note),
                  child: Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: note.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: InkWell(
                      onTap: () => _editNote(note),
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            if (note.content.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                note.content,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: const Color(0xFF1A1A1A).withOpacity(0.8),
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: _addNewNote,
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  void _deleteNote(int index, Note note) {
    setState(() {
      _notes.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _notes.insert(index, note);
            });
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addNewNote() async {
    final nextColor = _getNextNoteColor();
    final result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(
          initialColor: nextColor,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _notes.add(result);
      });
    }
  }

  void _editNote(Note note) async {
    final result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(note: note),
      ),
    );

    if (result != null) {
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        setState(() {
          _notes[index] = result;
        });
      }
    }
  }
} 