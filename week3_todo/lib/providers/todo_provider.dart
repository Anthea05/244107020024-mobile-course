import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo {
  Todo(this.title, {this.done = false});
  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(title ?? this.title, done: done ?? this.done);
}

class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() {
    return [];
  }

  void add(String title) => state = [...state, Todo(title)];

  // Catatan: toggle & remove sengaja diubah dari berbasis `index` jadi
  // berbasis objek `Todo` itu sendiri. Ini penting karena sekarang ada
  // fitur filter (lihat filteredTodoListProvider di bawah) — kalau UI
  // sedang nampilin daftar yang sudah difilter, `index` di layar BEDA
  // dengan `index` di state asli. Kalau tetap pakai index, bisa salah
  // centang/hapus tugas yang lain.
  void toggle(Todo todo) {
    final index = state.indexOf(todo);
    if (index == -1) return;
    final todos = [...state];
    todos[index] = todos[index].copyWith(done: !todos[index].done);
    state = todos;
  }

  void remove(Todo todo) {
    state = state.where((t) => t != todo).toList();
  }
}

final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

// ------------------------------------------------------------
// FILTER
// ------------------------------------------------------------
// Enum buat 3 pilihan filter yang biasa dipakai di aplikasi Todo.
enum TodoFilter { all, active, completed }

// Notifier kecil buat nyimpen filter yang sedang dipilih (default: semua).
// Dipakai Notifier (bukan StateProvider) karena flutter_riverpod versi
// terbaru sudah tidak menyertakan StateProvider — semua pola state
// sekarang disatukan lewat Notifier/AsyncNotifier.
class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  void set(TodoFilter filter) => state = filter;
}

final todoFilterProvider =
    NotifierProvider<TodoFilterNotifier, TodoFilter>(TodoFilterNotifier.new);

final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  return switch (filter) {
    TodoFilter.active => todos.where((todo) => !todo.done).toList(),
    TodoFilter.completed => todos.where((todo) => todo.done).toList(),
    TodoFilter.all => todos,
  };
});