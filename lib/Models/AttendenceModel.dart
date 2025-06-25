// AttendenceModel.dart

class AttendanceRecord {
  final int? attendanceId;
  final int? userId;
  final String userName;
  final String date;
  final String punchIn;
  final String punchOut;
  final String totalHours;

  AttendanceRecord({
    required this.attendanceId,
    required this.userId,
    required this.userName,
    required this.date,
    required this.punchIn,
    required this.punchOut,
    required this.totalHours,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    String punchIn = json['punch_in'] ?? '';
    String punchOut = json['punch_out'] ?? '';
    String date =
        punchIn.contains(' ') ? punchIn.split(' ').sublist(2).join(' ') : '';

    return AttendanceRecord(
      attendanceId: json['attendance_id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? 'N/A',
      punchIn: punchIn.trim(),
      punchOut: punchOut.trim(),
      totalHours: json['total_hours'] ?? '0',
      date: date,
    );
  }
}
