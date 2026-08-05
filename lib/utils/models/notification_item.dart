class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime? createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['notification_type'] as String? ?? 'system',
      read: json['read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  NotificationItem copyWith({bool? read}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }
}
