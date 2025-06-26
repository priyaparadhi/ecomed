import 'package:ecomed/Models/CommentModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentLogScreen extends StatelessWidget {
  final List<CommentLog> commentLogs = [
    CommentLog(
        user: 'Rohit',
        comment: 'Updated enquiry status to Follow-up.',
        timestamp: '2025-06-26T10:30:00'),
    CommentLog(
        user: 'Darshan',
        comment: 'Added note: Client will confirm by Friday.',
        timestamp: '2025-06-25T16:45:00'),
    CommentLog(
        user: 'System',
        comment: 'Auto-created enquiry from form submission.',
        timestamp: '2025-06-25T09:12:00'),
  ];

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('d MMM, h:mm a').format(dt);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comment Log"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF4F6FA),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: commentLogs.length,
        itemBuilder: (context, index) {
          final comment = commentLogs[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigo.shade100,
                  child: Text(
                    comment.user[0].toUpperCase(),
                    style: const TextStyle(color: Colors.indigo),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.user,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(comment.timestamp),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        comment.comment,
                        style: const TextStyle(fontSize: 14.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
