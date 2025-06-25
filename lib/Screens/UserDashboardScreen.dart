import 'dart:convert';

import 'package:ecomed/Screens/DailyPlan/DailyPlanList.dart';
import 'package:ecomed/Screens/EmployeeLeave/LeaveTracker.dart';
import 'package:ecomed/Screens/Tasks/Tasks/TaskList.dart';
import 'package:ecomed/styles/DrawerWidget.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as kit;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final Color primaryColor = Colors.blue.shade800;
  final Color secondaryColor = Colors.blue.shade300;
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChange: (value) {
      final displayTime =
          StopWatchTimer.getDisplayTime(value, milliSecond: false);
      // print('Display Time: $displayTime');
    },
  );

  var backColor;
  late bool light;
  bool checkLocation = false;
  String punch_Status = "";
  late String urlAnime;
  String profileUrl = "";
  Stopwatch _stopwatch = Stopwatch();
  String _elapsedTime = '';
  int roleId = 0;
  bool _isCheckingIn = true;
  bool isLoading = false;
  bool _isCheckingLocation = false;

  Future<Position> _determinePosition() async {
    setState(() {
      _isCheckingLocation = true; // Show Lottie animation
    });

    List<kit.LatLng> poligonlatslongs = [
      kit.LatLng(18.5944166, 73.7917032),
      kit.LatLng(18.5942322, 73.7928545),
      kit.LatLng(18.5941796, 73.7928305),
      kit.LatLng(18.5947532, 73.7932197),
      kit.LatLng(18.5946136, 73.7935348),
      kit.LatLng(18.5941001, 73.7934851),
      kit.LatLng(18.5939405, 73.7932565),
    ];

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Turn On Location"),
        backgroundColor: Colors.red,
      ));

      setState(() {
        _isCheckingLocation = false; // Hide Lottie animation
      });

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isCheckingLocation = false; // Hide Lottie animation
        });
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isCheckingLocation = false; // Hide Lottie animation
      });
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final position = await Geolocator.getCurrentPosition();
    print(position.latitude);
    print(position.longitude);

    setState(() {
      checkLocation = kit.PolygonUtil.containsLocation(
          kit.LatLng(position.latitude, position.longitude),
          poligonlatslongs,
          false);
      _isCheckingLocation = false;
    });

    // if (!checkLocation) {
    //   _showOutOfBoundsDialog();
    // }

    print(checkLocation);
    return position;
  }

  void _showOutOfBoundsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Outside Premises"),
          content: Text("You are not within the designated premises."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> openscanner() async {
    try {
      final pref = await SharedPreferences.getInstance();

      Uri url = Uri.parse(
          'https://ecomed-dev.portalwiz.in/api/public/api/add_attendance?');
      Uri urlfetchAttendance = Uri.parse(
          "https://ecomed-dev.portalwiz.in/api/public/api/fetch_attendance?");

      var payload = {
        "account_id": pref.getInt('account_id').toString(),
        "user_id": pref.getInt('user_id').toString(),
        "punch_status": pref.getInt('punch_Status').toString()
      };

      var payloadForFetch = {
        "account_id": pref.getInt('account_id').toString(),
        "user_id": pref.getInt('user_id').toString(),
      };

      final response = await http.post(url, body: payload);

      final responseAttendence =
          await http.post(urlfetchAttendance, body: payloadForFetch);

      print(jsonDecode(responseAttendence.body)["data"]);

      var data = jsonDecode(response.body.toString());

      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              pref.getInt('punch_Status') == 1 ? "Have a Great Day" : "Bye!!"),
          backgroundColor: pref.getInt('punch_Status') == 1
              ? Colors.greenAccent
              : Colors.blueAccent,
        ));
        pref.setInt('punch_Status', pref.getInt('punch_Status') == 1 ? 0 : 1);
      }

      return {
        'punch_status': data['punch_status'],
        'time': getTime(responseAttendence)
      };
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Sorry failed to scan Try Again"),
        backgroundColor: Colors.redAccent,
      ));
      return null;
    }
  }

  String? timedata;
  String getTime(http.Response responseAttendence) {
    final data = jsonDecode(responseAttendence.body);
    final List<Map<String, dynamic>> attendanceData =
        List<Map<String, dynamic>>.from(data['data']);
    final latestAttendance = attendanceData.last;
    timedata = latestAttendance['time'];
    return latestAttendance['time'];
  }

  // void getPunched() async {
  //   final pref = await SharedPreferences.getInstance();
  //   await ApiCalls.getStatus(pref.getInt('account_id') ?? 0);
  //   setState(() {
  //     roleId = pref.getInt("role_id") ?? 0;
  //     profileUrl = pref.getString('profile_path') ?? "";
  //     if (pref.getInt('punch_Status') == 1) {
  //       backColor = Colors.greenAccent;
  //       light = false;
  //       urlAnime = "asset/animation/Animation - 1706007149763.json";
  //     } else {
  //       backColor = Colors.redAccent;

  //       light = true;

  //       urlAnime = "asset/animation/Animation - 1706007655831.json";
  //     }
  //   });
  // }

  @override
  void initState() {
    fetchAttendanceData();

    //getPunched();

    //_determinePosition();

    super.initState();
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> fetchAttendanceData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      Uri urlfetchAttendance = Uri.parse(
          "https://ecomed-dev.portalwiz.in/api/public/api/fetch_attendance");

      var payloadForFetch = {
        "account_id": pref.getInt('account_id')?.toString() ?? '',
        "user_id": pref.getInt('user_id')?.toString() ?? '',
      };

      final responseAttendance =
          await http.post(urlfetchAttendance, body: payloadForFetch);

      if (responseAttendance.statusCode == 200) {
        var data = jsonDecode(responseAttendance.body);
        var latestRecord = data.first;
        if (data.isNotEmpty) {
          // Get the latest record (assuming the first one is the latest)

          int attendanceId = latestRecord['attendance_id'];
          await pref.setInt('attendance_id', attendanceId);
          print('Stored attendance_id: $attendanceId');
          print('Stored data: $data');

          String? inTimeStr = latestRecord['in_time'];
          String? dateStr = latestRecord['date'];
          String? outTime = latestRecord['out_time'];

          if (((inTimeStr != null) || (dateStr != null) || (outTime != null)) &&
              ("${latestRecord['punch_status']}"
                  .toLowerCase()
                  .contains('in'))) {
            DateTime checkinDateTime = DateTime.parse('$dateStr $inTimeStr');

            DateTime currentDate = DateTime.now();

            // Calculate the difference in time
            if (currentDate.isAfter(checkinDateTime)) {
              Duration timeDifference = currentDate.difference(checkinDateTime);

              // Use the time difference for setting the timer
              _stopWatchTimer.clearPresetTime();
              _stopWatchTimer.setPresetHoursTime(timeDifference.inHours);
              _stopWatchTimer
                  .setPresetMinuteTime(timeDifference.inMinutes.remainder(60));
              _stopWatchTimer
                  .setPresetSecondTime(timeDifference.inSeconds.remainder(60));
              _stopWatchTimer.onStartTimer();
            } else {
              _stopWatchTimer.clearPresetTime();
              _stopWatchTimer.setPresetHoursTime(0);
              _stopWatchTimer.setPresetMinuteTime(0);
              _stopWatchTimer.setPresetSecondTime(0);
              _stopWatchTimer.onStartTimer();
            }

            return {
              'punch_status':
                  "${latestRecord['punch_status']}".toLowerCase().contains('in')
                      ? 0
                      : 1,
              'time':
                  "${latestRecord['punch_status']}".toLowerCase().contains('in')
                      ? latestRecord['in_time']
                      : latestRecord['out_time'],
              'created_at': latestRecord['created_at'],
            };
          } else {
            _stopWatchTimer.onStopTimer();

            return {
              'punch_status':
                  "${latestRecord['punch_status']}".toLowerCase().contains('in')
                      ? 0
                      : 1,
              'time': latestRecord['punch_status'].contains('in')
                  ? latestRecord['in_time']
                  : latestRecord['out_time'],
              'created_at': latestRecord['created_at'],
            };
          }
        } else {
          throw Exception('No attendance data available');
        }
      } else {
        throw Exception('Failed to fetch attendance data');
      }
    } catch (e) {
      print("Exception $e");
      return null;
    }
  }

  Future<int?> handlePunchInOut(int status) async {
    print(status);
    try {
      final pref = await SharedPreferences.getInstance();

      Uri url = Uri.parse((status == 1)
          ? 'https://ecomed-dev.portalwiz.in/api/public/api/add_attendance'
          : 'https://ecomed-dev.portalwiz.in/api/public/api/edit_attendance');

      print(url.path);

      var punchStatus = status;
      print('Initial Punch Status: $punchStatus');

      var payload = {
        "attendance_id":
            (status == 0) ? "${pref.getInt('attendance_id')}" : null,
        "account_id": pref.getInt('account_id')?.toString() ?? '',
        "user_id": pref.getInt('user_id')?.toString() ?? '',
        "punch_status": (punchStatus == 0) ? "1" : "0",
      };
      if (punchStatus == 1) {
        payload["in_time"] =
            "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
      }
      if (punchStatus == 0) {
        payload["out_time"] =
            "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
      }

      print('Request Payload: $payload');
      final response = await http.post(
        url,
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      var data = jsonDecode(response.body.toString());

      if (data['success']) {
        if (punchStatus == 0) {
          _stopWatchTimer.onResetTimer();
          _stopWatchTimer.onStartTimer();
        } else {
          _stopWatchTimer.onStopTimer();
          final workTime = StopWatchTimer.getDisplayTime(
              _stopWatchTimer.rawTime.value,
              milliSecond: false);
          print('Total Work Time: $workTime');
        }

        punchStatus = punchStatus == 0 ? 1 : 0;
        pref.setInt('punch_Status', punchStatus);
        print('Updated Punch Status: $punchStatus');

        return punchStatus;
      } else {
        return null;
      }
    } on PlatformException {
      return null;
    }
  }

  void _showAlertDialog(bool visi) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white,
                ),
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // if (true)
                    //   SizedBox(
                    //     width: 100,
                    //     height: 100,
                    //     child: Lottie.asset('assets/animation/empty.json'),
                    //   ),
                    Text(
                      "Attendance",
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 20),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: fetchAttendanceData(),
                      builder: (context, snapshot) {
                        print("Data55  $snapshot");
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                          // } else if (!snapshot.hasData || snapshot.data == null) {
                          //   return Text("No attendance data available.");
                        } else {
                          var data = snapshot?.data;
                          var punchStatus = data?['punch_status'] ?? 1;
                          var time = data?['time'];
                          var createdAt = data?['created_at'];

                          DateTime? createdDateTime;
                          String formattedDate = '';

                          if (createdAt != null) {
                            createdDateTime = DateTime.parse(createdAt);
                            formattedDate = DateFormat('dd-MM-yyyy')
                                .format(createdDateTime);
                          }

                          String displayTime = '';
                          if (punchStatus == 0) {
                            displayTime = time != null
                                ? "Checked In Time: $time\n($formattedDate)"
                                : "Not Checked In Yet";
                          } else {
                            displayTime = time != null
                                ? "Checked Out Time: $time\n($formattedDate)"
                                : "Not Checked Out Yet";
                          }

                          return Column(
                            children: [
                              Text(
                                displayTime,
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Total in hours",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              StreamBuilder<int>(
                                stream: _stopWatchTimer.rawTime,
                                initialData: _stopWatchTimer.rawTime.value,
                                builder: (context, snap) {
                                  final value = snap.data!;
                                  final displayTime =
                                      StopWatchTimer.getDisplayTime(value,
                                          milliSecond: false);
                                  return Text(
                                    displayTime,
                                    style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  SharedPreferences preferences =
                                      await SharedPreferences.getInstance();

                                  // if (!(preferences.getBool("privacy_Terms") ?? false)) {
                                  //   termsAndCondition();
                                  // }

                                  if (true) {
                                    Map<String, dynamic>? datanew =
                                        await fetchAttendanceData();

                                    int? punchStatus = await handlePunchInOut(
                                        datanew?['punch_status'] ?? 1);
                                    if (punchStatus != null) {
                                      Navigator.of(dialogContext).pop();
                                      showLottieAnimation(
                                          punchStatus); // Replace with your Lottie animation method
                                    } else {
                                      print("Punch in/out failed");
                                    }
                                  }
                                  // else {
                                  //   // _determinePosition(); // Commented out as requested
                                  //   print("Sorry!!!!");
                                  // }
                                },
                                child: Text(
                                  punchStatus == 0 ? "Check out" : "Check In",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 35, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  backgroundColor: punchStatus == 0
                                      ? Color.fromARGB(255, 230, 102, 102)
                                      : Color.fromARGB(255, 76, 175, 172),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showLottieAnimation(int punchStatus) {
    String animationPath = punchStatus == 1
        ? 'assets/animation/Animation - 1706007655831.json'
        : 'assets/animation/check_in.json';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Lottie.asset(
            animationPath,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            repeat: false,
            onLoaded: (composition) {
              Future.delayed(Duration(seconds: composition.duration.inSeconds),
                  () {
                Navigator.of(context).pop();
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      drawer: DrawerWidget(),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, Priya 👋',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Overview Cards
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                UserStatCard(
                    title: 'Completed Tasks',
                    count: 12,
                    icon: LucideIcons.checkCircle2,
                    color: Colors.green),
                UserStatCard(
                    title: 'Pending Tasks',
                    count: 8,
                    icon: LucideIcons.clock,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TaskListPage()));
                    }),
                UserStatCard(
                    title: 'Completed Plans',
                    count: 6,
                    icon: LucideIcons.calendarCheck,
                    color: Colors.teal),
                UserStatCard(
                    title: 'Pending Plans',
                    count: 4,
                    icon: LucideIcons.calendarClock,
                    color: Colors.red,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DailyPlanPage()));
                    }),
                UserStatCard(
                    title: 'Attendance',
                    count: 22,
                    icon: LucideIcons.userCheck,
                    color: Colors.indigo),
                UserStatCard(
                    title: 'Leaves',
                    count: 2,
                    icon: LucideIcons.leaf,
                    color: Colors.deepPurple,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LeaveTracker()));
                    }),
              ],
            ),

            const SizedBox(height: 32),
            const SectionTitle(label: 'Plan Completion'),
            const SizedBox(height: 12),
            SizedBox(
                height: 200,
                child: TaskCompletionChart(primaryColor: Colors.teal)),

            const SizedBox(height: 32),
            const SectionTitle(label: 'Weekly Attendance'),
            const SizedBox(height: 12),
            SizedBox(
                height: 240,
                child: WeeklyAttendanceChart(primaryColor: Colors.indigo)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.checklist),
        onPressed: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          Position position = await _determinePosition();
          print(position);
          _showAlertDialog(false);
        },
      ),
    );
  }
}

// Reusable Card
class UserStatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const UserStatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 12),
              Text('$count',
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 6),
              Text(title,
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

// Section Title
class SectionTitle extends StatelessWidget {
  final String label;
  const SectionTitle({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

// Pie Chart
class TaskCompletionChart extends StatelessWidget {
  final Color primaryColor;

  const TaskCompletionChart({required this.primaryColor, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 40,
          sectionsSpace: 4,
          sections: [
            PieChartSectionData(
              color: primaryColor,
              value: 75,
              title: '75%\nDone',
              titleStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              radius: 60,
            ),
            PieChartSectionData(
              color: Colors.grey.shade300,
              value: 25,
              title: '25%\nPending',
              titleStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              radius: 60,
            ),
          ],
        ),
      ),
    );
  }
}

// Bar Chart
class WeeklyAttendanceChart extends StatelessWidget {
  final Color primaryColor;

  const WeeklyAttendanceChart({required this.primaryColor, super.key});

  @override
  Widget build(BuildContext context) {
    final data = [8, 7, 9, 8, 6, 7, 5];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: BarChart(
        BarChartData(
          maxY: 10,
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: data[i].toDouble(),
                width: 16,
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [primaryColor.withOpacity(0.8), primaryColor],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 10,
                  color: Colors.grey.shade200,
                ),
              )
            ]);
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[value.toInt()],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 30,
                showTitles: true,
                interval: 2,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
