import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodoListProvider);
    final filter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Riverpod'),
        actions: [
          PopupMenuButton<TodoFilter>(
            initialValue: filter,
            onSelected: (value) =>
                ref.read(todoFilterProvider.notifier).set(value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: TodoFilter.all, child: Text('Semua')),
              PopupMenuItem(
                value: TodoFilter.active,
                child: Text('Belum selesai'),
              ),
              PopupMenuItem(
                value: TodoFilter.completed,
                child: Text('Selesai'),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: todos.isEmpty
          ? const Center(child: Text('Belum ada tugas'))
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return TodoTile(
                  todo: todo,
                  onToggle: () =>
                      ref.read(todoListProvider.notifier).toggle(todo),
                  onDelete: () =>
                      ref.read(todoListProvider.notifier).remove(todo),

                  onTap: () => context.push('/todo/${todo.id}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add), // Ikon yang dicari robot
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ), // TextField yang dicari robot
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(todoListProvider.notifier).add(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'), // Tombol yang dicari robot
          ),
        ],
      ),
    );
  }
}
