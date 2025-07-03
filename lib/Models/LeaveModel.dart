class LeaveHistory {
  final int leaveId;
  final String leaveName;
  final String dateFrom;
  final String dateTo;
  final double noOfDays;
  final String status;
  final String? comment;
  final String? requestType;
  LeaveHistory({
    required this.leaveId,
    required this.leaveName,
    required this.dateFrom,
    required this.dateTo,
    required this.noOfDays,
    required this.status,
    this.comment,
    required this.requestType,
  });

  factory LeaveHistory.fromJson(Map<String, dynamic> json) {
    return LeaveHistory(
      leaveId: json['leave_id'] ?? 0,
      leaveName: json['leave_type'] ?? '',
      dateFrom: json['date_from'] ?? '',
      dateTo: json['date_to'] ?? '',
      noOfDays: double.tryParse(json['no_of_days'] ?? '0.0') ?? 0.0,
      status: json['status'] ?? 'Pending',
      comment: json['reason'],
      requestType: json['request_type'] ?? '',
    );
  }
}
