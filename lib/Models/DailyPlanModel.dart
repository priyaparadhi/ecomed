// models/DailyPlanModel.dart

class DailyPlan {
  final int planId;
  final int userId;
  final String planName;
  final String planDate;
  String achievements;
  String comments;
  final String? userName;
  final String? taskName;
  final String? status;
  final String? priority;
  int statusId;
  final String? location;
  DailyPlan({
    required this.planId,
    required this.userId,
    required this.planName,
    required this.planDate,
    required this.achievements,
    required this.comments,
    this.userName,
    this.taskName,
    this.status,
    this.priority,
    required this.statusId,
    required this.location,
  });

  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    return DailyPlan(
      planId: json['plan_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      planName: json['plan_name'] ?? '',
      planDate: json['plan_date'] ?? '',
      achievements: json['achievements'] ?? '',
      comments: json['comments'] ?? 'N/A',
      userName: json['user_name'],
      taskName: json['task_name'],
      status: json['status'], // If you start receiving status from API
      priority: json['priority_name'],
      statusId: json['status_id'] ?? 0,
      location: json['gps_location'] ?? '',
    );
  }
}
