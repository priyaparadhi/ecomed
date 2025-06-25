import 'package:flutter/material.dart';
import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Models/Timesheetmodel.dart';
import 'package:intl/intl.dart';

class TimesheetPage extends StatefulWidget {
  const TimesheetPage({Key? key}) : super(key: key);

  @override
  State<TimesheetPage> createState() => _TimesheetPageState();
}

class _TimesheetPageState extends State<TimesheetPage> {
  List<TimesheetEntry> _entries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTimesheet();
  }

  Future<void> _fetchTimesheet() async {
    try {
      final entries = await ApiCalls.fetchTimesheetByUser();
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Timesheet",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : _entries.isEmpty
                  ? const Center(child: Text("No timesheet entries found."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        return _buildTimesheetCard(_entries[index]);
                      },
                    ),
    );
  }

  Widget _buildTimesheetCard(TimesheetEntry entry) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Day & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.day,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  entry.date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            /// Project & Task
            Text(
              entry.projectName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.taskName,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const Divider(height: 16),

            /// Times
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timeInfo("Start Time", _formatTimeWithAmPm(entry.startTime)),
                _timeInfo("End Time", _formatTimeWithAmPm(entry.endTime)),
                _timeInfo("Hours", entry.hours),
              ],
            ),
            const SizedBox(height: 12),

            /// Comments
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.comment_outlined,
                    size: 18, color: Colors.teal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    entry.comments,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeWithAmPm(String time24h) {
    try {
      final parsedTime = DateFormat("HH:mm").parse(time24h);
      return DateFormat("hh:mm a").format(parsedTime);
    } catch (e) {
      return time24h; // fallback if parsing fails
    }
  }

  Widget _timeInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
