import 'package:ecomed/Screens/Attendence/AttendenceHistory.dart';
import 'package:ecomed/Screens/DailyPlan/EmployeesDailyPlans.dart';
import 'package:ecomed/Screens/DailyPlan/completedUserPlan.dart';
import 'package:ecomed/Screens/EmployeeLeave/LeaveRequest.dart';
import 'package:ecomed/Screens/Tasks/Tasks/AddTaskPage.dart';
import 'package:ecomed/Screens/Tasks/employessTasks.dart';
import 'package:ecomed/styles/DrawerWidget.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HRDashboardScreen extends StatelessWidget {
  const HRDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      drawer: DrawerWidget(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Task Distribution'),
            _buildTaskPieChart(),
            const SizedBox(height: 24),
            _buildSectionTitle('Weekly Attendance'),
            _buildAttendanceBarChart(),
            const SizedBox(height: 24),
            _buildSectionTitle('Overview'),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _dashboardCard(LucideIcons.checkCircle2, 'Completed Plans', 124,
                    Colors.greenAccent.shade100, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CompleteDailyPlan()),
                  );
                }),
                _dashboardCard(
                  LucideIcons.clock,
                  'Pending Plans',
                  32,
                  Colors.orangeAccent.shade100,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DailyPlanPageForAdmin()),
                    );
                  },
                ),
                _dashboardCard(
                  LucideIcons.calendarDays,
                  'Leaves',
                  10,
                  Colors.deepPurpleAccent.shade100,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LeaveRequest()),
                    );
                  },
                ),
                _dashboardCard(
                  LucideIcons.userCheck,
                  'Attendance',
                  95,
                  Colors.lightBlueAccent.shade100,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AttendanceHistoryPage()),
                    );
                  },
                ),
                _dashboardCard(LucideIcons.clipboardList, 'Tasks', 15,
                    Colors.tealAccent.shade100, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EmployeesTasksPage()),
                  );
                }),
                _dashboardCard(LucideIcons.users2, 'Total Employees', 50,
                    Colors.cyanAccent.shade100),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _dashboardCard(
    IconData icon,
    String title,
    int count,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32, color: Colors.black54),
            Text(
              '$count',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskPieChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 8),
        ],
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: 124,
              color: Colors.green.shade400,
              title: 'Completed',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            PieChartSectionData(
              value: 32,
              color: Colors.orange.shade400,
              title: 'Pending',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceBarChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 8),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueAccent.shade100,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} hrs',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (value, _) => Text('${value.toInt()}'),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun'
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(days[value.toInt() % 7]),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barGroups: [
            _buildBar(0, 8),
            _buildBar(1, 7),
            _buildBar(2, 9),
            _buildBar(3, 8),
            _buildBar(4, 6),
            _buildBar(5, 7),
            _buildBar(6, 5),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blueAccent,
          width: 16,
          borderRadius: BorderRadius.circular(8),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: Colors.grey.shade200,
          ),
        ),
      ],
    );
  }
}
