// api_calls.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

class Task {
  final int taskId;
  final String taskName;
  final String assignedToNames;
  final String taskStartDate;
  final String taskEndDate;
  final String priority;
  final String status;
  final String createdByName;
  final int taskStatusId;

  Task({
    required this.taskId,
    required this.taskName,
    required this.assignedToNames,
    required this.taskStartDate,
    required this.taskEndDate,
    required this.priority,
    required this.status,
    required this.createdByName,
    required this.taskStatusId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['task_id'],
      taskName: json['task_name'] ?? '',
      assignedToNames: json['assigned_to_names'] ?? '',
      taskStartDate: json['task_start_date'] ?? '',
      taskEndDate: json['task_end_date'] ?? '',
      priority: json['priority'] ?? '',
      status: json['task_status'] ?? '',
      createdByName: json['created_by_name'] ?? '',
      taskStatusId: json['task_status_id'],
    );
  }
}
