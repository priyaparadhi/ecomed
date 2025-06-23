import 'package:ecomed/EmployeeLeave/LeaveTracker.dart';
import 'package:ecomed/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaveHistoryCard extends StatelessWidget {
  final LeaveHistory leave;

  const LeaveHistoryCard({Key? key, required this.leave}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //dgeInsets.all(8.0),
    return Appstyles.cardStyle(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.leaveName,
                      style: GoogleFonts.lato(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.0),
                    Text('Days: ${leave.noOfDays.toStringAsFixed(1)}',
                        style: GoogleFonts.lato()),
                    SizedBox(height: 4.0),
                    Text('Date: ${leave.dateFrom} - ${leave.dateTo}',
                        style: GoogleFonts.lato()),
                    Text(
                      'Comment: ${leave.comment?.isNotEmpty == true ? leave.comment : " "}',
                      style: GoogleFonts.lato(),
                      textAlign: TextAlign.justify,
                      maxLines:
                          3, // Set max lines to 3 or remove this line for unlimited lines
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${leave.status}',
                        style: GoogleFonts.lato(
                            color: leave.status == 'Approved'
                                ? const Color.fromARGB(139, 3, 144, 22)
                                : const Color.fromARGB(255, 247, 168, 50),
                            fontWeight: FontWeight.bold,
                            fontSize: 11),
                      ),
                    ))
              ],
            )),
      ),
    );
  }
}
