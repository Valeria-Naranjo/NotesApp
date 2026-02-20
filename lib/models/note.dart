class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime? reminder;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.reminder,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      content: map['content'],
      reminder: map['reminder'] != null
          ? DateTime.parse(map['reminder'])
          : null,
    );
  }
}