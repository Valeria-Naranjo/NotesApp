class Event {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime date;
  final DateTime? reminder;

  Event({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    this.reminder,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'].toString(),
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      reminder: map['reminder'] != null
          ? DateTime.parse(map['reminder'])
          : null,
    );
  }
}