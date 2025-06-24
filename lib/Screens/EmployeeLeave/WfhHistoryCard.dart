import 'package:ecomed/Screens/EmployeeLeave/LeaveTracker.dart';
import 'package:ecomed/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WfhHistoryCard extends StatelessWidget {
  final WfhHistory wfh;

  const WfhHistoryCard({Key? key, required this.wfh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      'WFH Request',
                      style: GoogleFonts.lato(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.0),
                    Text('Days: ${wfh.noOfDays.toStringAsFixed(1)}',
                        style: GoogleFonts.lato()),
                    Text('Date: ${wfh.dateFrom} - ${wfh.dateTo}',
                        style: GoogleFonts.lato()),
                    Text(
                      'Comment: ${wfh.comment ?? ''}',
                      style: GoogleFonts.lato(),
                      textAlign: TextAlign.justify,
                      maxLines: 3,
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
                        border: Border.all(color: Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${wfh.status}',
                        style: GoogleFonts.lato(
                            color: wfh.status == 'Approved'
                                ? const Color.fromARGB(139, 3, 144, 22)
                                : const Color.fromARGB(255, 247, 168, 50),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ))
              ],
            )),
      ),
    );
  }
}
