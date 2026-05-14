import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../../providers/university_provider.dart';
import '../../widgets/note_card.dart';
import '../settings_screen.dart';
import '../teacher/upload_note_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final notesProvider = Provider.of<NotesProvider>(context);
    final uniProvider = Provider.of<UniversityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${authProvider.currentUser?.name ?? "Student"} (${authProvider.currentUser?.semester ?? "Sem unknown"})',
              style: const TextStyle(fontSize: 14, color: Color(0xFF8B949E)),
            ),
            const Text('Smart Notes Hub', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF00BFA5)),
            onPressed: () => _showNotifications(context, uniProvider),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF8B949E)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedIndex == 0) _buildSearchBar(notesProvider),
          Expanded(
            child: _buildBody(notesProvider, uniProvider),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadNoteScreen())),
        label: const Text('Contribute', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.upload_file, color: Colors.black),
        backgroundColor: const Color(0xFF00BFA5),
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Hub'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favs'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Shared'),
        ],
      ),
    );
  }

  Widget _buildSearchBar(NotesProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => provider.setSearchQuery(val),
        decoration: InputDecoration(
          hintText: 'Search semester, course, tags...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: const Color(0xFF1C222D),
        ),
      ),
    );
  }

  Widget _buildBody(NotesProvider notes, UniversityProvider uni) {
    switch (_selectedIndex) {
      case 0: return _buildNotesList(notes.approvedNotes, notes);
      case 1: return _buildEventsList(uni);
      case 2: return _buildNotesList(notes.favoriteNotes, notes);
      case 3: return _buildNotesList(notes.sharedNotes, notes);
      default: return const Center(child: Text('Coming Soon'));
    }
  }

  Widget _buildNotesList(List notes, NotesProvider provider) {
    if (notes.isEmpty) return const Center(child: Text('No notes found.'));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notes.length,
      itemBuilder: (context, index) => NoteCard(note: notes[index]),
    );
  }

  Widget _buildEventsList(UniversityProvider provider) {
    if (provider.events.isEmpty) return const Center(child: Text('No upcoming events.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.events.length,
      itemBuilder: (context, index) {
        final event = provider.events[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.event_available, color: Colors.blue),
            title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${event.description}\n@ ${event.location}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _showNotifications(BuildContext context, UniversityProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('University Announcements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...provider.notifications.map((n) => ListTile(
            leading: const Icon(Icons.campaign, color: Colors.orange),
            title: Text(n.title),
            subtitle: Text(n.message),
          )),
        ],
      ),
    );
  }
}
