import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Models/AttendenceModel.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class MyAttendanceHistoryPage extends StatefulWidget {
  const MyAttendanceHistoryPage({Key? key}) : super(key: key);

  @override
  State<MyAttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<MyAttendanceHistoryPage> {
  List<AttendanceRecord> records = [];
  bool _isLoading = true;
  String? _error;
  DatePickerController _dateController = DatePickerController();
  DateTime _selectedDate = DateTime.now();
  DateTime _startDate = DateTime.now().subtract(Duration(days: 20));
  List<Map<String, dynamic>> _assignedUsers = [];
  int? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ApiCalls.fetchMyAttendence(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      );

      setState(() {
        records = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onDateChange(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Attendance History",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Date Picker Timeline
          Container(
            height: 100,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            child: DatePicker(
              _startDate,
              initialSelectedDate: _selectedDate,
              selectionColor: Colors.blue,
              selectedTextColor: Colors.white,
              daysCount: 365,
              controller: _dateController,
              onDateChange: (date) {
                _onDateChange(date);
                print('Selected date: $date');
              },
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text("Error: $_error"))
                    : records.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                "No attendance for ${DateFormat('dd MMM yyyy').format(_selectedDate)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              return _buildAttendanceCard(
                                  records[index], index);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(AttendanceRecord record, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + index * 50),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: Colors.blueAccent,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  record.date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoChip(
                    label: "Punch In",
                    value: record.punchIn,
                    color: Colors.green),
                _infoChip(
                    label: "Punch Out",
                    value: record.punchOut,
                    color: Colors.redAccent),
                _infoChip(
                    label: "Total",
                    value: record.totalHours,
                    color: Colors.blueAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip({
    required String label,
    required String? value,
    required Color color,
  }) {
    final isValueValid = value != null && value.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        if (isValueValid)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          )
        else
          const Text(
            "-",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black26,
            ),
          ),
      ],
    );
  }
}
