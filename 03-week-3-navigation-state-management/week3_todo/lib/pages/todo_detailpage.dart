import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/todo_provider.dart';

// Halaman ini dibuka lewat context.push('/todo/$id'), bukan lewat
// NavigationBar. Karena di-push (bukan diganti/go), Flutter otomatis
// nampilin tombol back di AppBar, dan halaman ini bisa diakses langsung
// lewat URL/path-nya (misal dari deep link atau ditulis manual di
// address bar versi web).
class TodoDetailPage extends ConsumerWidget {
  const TodoDetailPage({super.key, required this.todoId});

  final int todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(todoByIdProvider(todoId));

    if (todo == null) {
      // Bisa kejadian kalau todo-nya sudah dihapus, atau id di URL
      // nggak valid (misal user ngetik path detail langsung tapi
      // aplikasi baru dibuka dan datanya masih kosong).
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tugas')),
        body: const Center(
          child: Text('Tugas tidak ditemukan (mungkin sudah dihapus).'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tugas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(todo.done ? 'Status: Selesai' : 'Status: Belum selesai'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.read(todoListProvider.notifier).toggle(todo),
              icon: Icon(todo.done ? Icons.undo : Icons.check),
              label: Text(todo.done ? 'Tandai belum selesai' : 'Tandai selesai'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(todoListProvider.notifier).remove(todo);
                context.pop(); // balik ke list setelah dihapus
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text(
                'Hapus tugas',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}