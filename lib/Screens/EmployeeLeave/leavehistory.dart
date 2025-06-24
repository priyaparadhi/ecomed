import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Screens/EmployeeLeave/LeaveHistoryCard.dart';
import 'package:ecomed/Screens/EmployeeLeave/LeaveTracker.dart';
import 'package:ecomed/Screens/EmployeeLeave/WfhHistoryCard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LeaveHistorySection extends StatefulWidget {
  Future<List<LeaveHistory>> futureLeaveHistory;
  Future<List<WfhHistory>> futureWfhHistory;

  LeaveHistorySection(
      {required this.futureLeaveHistory, required this.futureWfhHistory});
  @override
  _LeaveHistorySectionState createState() => _LeaveHistorySectionState();
}

class _LeaveHistorySectionState extends State<LeaveHistorySection> {
  @override
  void initState() {
    super.initState();
    callFunction();
  }

  void callFunction() async {
    widget.futureLeaveHistory = ApiCalls.fetchSingleEmployeeLeave();
    widget.futureWfhHistory = ApiCalls.fetchSingleEmployeeWFH();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([widget.futureLeaveHistory, widget.futureWfhHistory]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("${snapshot.error}"));
        }

        List<LeaveHistory>? leaveHistory = snapshot.data![0];
        List<WfhHistory>? wfhHistory = snapshot.data![1];

        leaveHistory?.sort((a, b) {
          DateTime dateA = DateTime.parse(a.dateFrom);
          DateTime dateB = DateTime.parse(b.dateFrom);
          return dateB.compareTo(dateA);
        });

        wfhHistory?.sort((a, b) {
          DateTime dateA = DateTime.parse(a.dateFrom);
          DateTime dateB = DateTime.parse(b.dateFrom);
          return dateB.compareTo(dateA);
        });

        if ((leaveHistory == null || leaveHistory.isEmpty) &&
            (wfhHistory == null || wfhHistory.isEmpty)) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Lottie.asset('assets/animation/notfound.json'),
                ),
                SizedBox(
                  height: 4, //MediaQuery.of(context).size.height * 0.001,
                ),
                Text(
                  'No Leave or WFH History',
                  style: GoogleFonts.lato(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            if (leaveHistory != null && leaveHistory.isNotEmpty)
              ...leaveHistory
                  .map((leave) => LeaveHistoryCard(leave: leave))
                  .toList(),
            if (wfhHistory != null && wfhHistory.isNotEmpty)
              ...wfhHistory.map((wfh) => WfhHistoryCard(wfh: wfh)).toList(),
          ],
        );
      },
    );
  }
}
