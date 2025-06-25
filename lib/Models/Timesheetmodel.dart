class TimesheetEntry {
  final String day;
  final String date;
  final String startTime;
  final String endTime;
  final String hours;
  final String comments;
  final String projectName;
  final String taskName;

  TimesheetEntry({
    required this.day,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.hours,
    required this.comments,
    required this.projectName,
    required this.taskName,
  });

  factory TimesheetEntry.fromJson(Map<String, dynamic> json) {
    return TimesheetEntry(
      day: json['day'] ?? '',
      date: json['work_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      hours: json['hours'].toString(),
      comments: json['comment'] ?? '',
      projectName: json['name'] ?? '',
      taskName: json['task_name'] ?? '',
    );
  }
}
