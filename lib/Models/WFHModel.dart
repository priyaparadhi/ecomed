class WfhHistory {
  final int wfhId;
  final double noOfDays;
  final String dateFrom;
  final String dateTo;
  final int wfhStatus;
  final String? comment;
  final String createdAt;
  final String status;

  WfhHistory({
    required this.wfhId,
    required this.noOfDays,
    required this.dateFrom,
    required this.dateTo,
    required this.wfhStatus,
    required this.comment,
    required this.createdAt,
    required this.status,
  });

  factory WfhHistory.fromJson(Map<String, dynamic> json) {
    return WfhHistory(
      wfhId: json['wfh_id'],
      noOfDays: double.parse(json['no_of_days']),
      dateFrom: json['date_from'],
      dateTo: json['date_to'],
      wfhStatus: json['wfh_status'],
      comment: json['reason'],
      createdAt: json['created_at'],
      status: json['status'] ?? 'Pending',
    );
  }
}
