class NotificationModel {
  final String id;
  final String userId;
  final String workId;
  final String type;
  final String title;
  final String description;
  final bool isRead;


  NotificationModel({
    required this.id,
    required this.userId,
    required this.workId,
    required this.type,
    required this.title,
    required this.description,
    required this.isRead,

  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      workId: json['work_id'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      isRead: json['is_read'],
    );
  }
}
