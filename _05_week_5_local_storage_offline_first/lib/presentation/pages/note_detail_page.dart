import 'package:flutter/material.dart';

import '../../data/local/note.dart';
import '../../data/repositories/note_repository.dart';

class NoteDetailPage extends StatelessWidget {
  final int noteId;
  final NoteRepository noteRepo;

  const NoteDetailPage({
    super.key,
    required this.noteId,
    required this.noteRepo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: FutureBuilder<Note?>(
        future: noteRepo.fetchNoteById(noteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final note = snapshot.data;
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        note.dirty ? 'Belum Tersinkron' : 'Tersinkron',
                      ),
                      backgroundColor: note.dirty
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      note.updatedAt.toString().substring(0, 16),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  note.body.isEmpty ? '(Tidak ada isi catatan)' : note.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
