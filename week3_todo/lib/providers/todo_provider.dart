import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo {
  Todo(this.title, {this.done = false, int? id})
    : id = id ?? DateTime.now().microsecondsSinceEpoch;

  final int id;
  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(title ?? this.title, done: done ?? this.done, id: id);
}

class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() {
    return [];
  }

  void add(String title) => state = [...state, Todo(title)];

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

final todoListProvider = NotifierProvider<TodoListNotifier, List<Todo>>(
  TodoListNotifier.new,
);

final todoByIdProvider = Provider.family<Todo?, int>((ref, id) {
  final todos = ref.watch(todoListProvider);
  for (final todo in todos) {
    if (todo.id == id) return todo;
  }
  return null;
});

enum TodoFilter { all, active, completed }

class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  void set(TodoFilter filter) => state = filter;
}

final todoFilterProvider = NotifierProvider<TodoFilterNotifier, TodoFilter>(
  TodoFilterNotifier.new,
);

final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  return switch (filter) {
    TodoFilter.active => todos.where((todo) => !todo.done).toList(),
    TodoFilter.completed => todos.where((todo) => todo.done).toList(),
    TodoFilter.all => todos,
  };
});
