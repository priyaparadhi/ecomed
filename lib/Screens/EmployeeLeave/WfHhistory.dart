import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Models/WFHModel.dart';
import 'package:ecomed/Screens/EmployeeLeave/WfhHistoryCard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class WfhHistorySection extends StatefulWidget {
  final Future<List<WfhHistory>>? futureWfhHistory;

  WfhHistorySection({this.futureWfhHistory});

  @override
  _WfhHistorySectionState createState() => _WfhHistorySectionState();
}

class _WfhHistorySectionState extends State<WfhHistorySection> {
  late Future<List<WfhHistory>> wfhHistoryFuture;

  @override
  void initState() {
    super.initState();
    wfhHistoryFuture =
        widget.futureWfhHistory ?? ApiCalls.fetchSingleEmployeeWFH();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WfhHistory>>(
      future: wfhHistoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("${snapshot.error}"));
        }

        List<WfhHistory>? wfhHistory = snapshot.data;

        wfhHistory?.sort((a, b) {
          DateTime dateA = DateTime.parse(a.dateFrom);
          DateTime dateB = DateTime.parse(b.dateFrom);
          return dateB.compareTo(dateA);
        });

        if (wfhHistory == null || wfhHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Lottie.asset('assets/animation/notfound.json'),
                ),
                SizedBox(height: 4),
                Text(
                  'No WFH History',
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
          children: wfhHistory.map((wfh) => WfhHistoryCard(wfh: wfh)).toList(),
        );
      },
    );
  }
}
