class Note {
  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;

  Note({
    this.id,
    required this.title,
    this.body = '',
    DateTime? updatedAt,
    this.dirty = false,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: (map['title'] ?? '') as String,
      body: (map['body'] ?? '') as String,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      dirty: map['dirty'] == 1 || map['dirty'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'body': body,
      'updated_at': updatedAt.toIso8601String(),
      'dirty': dirty ? 1 : 0,
    };
  }
}