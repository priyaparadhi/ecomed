import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Models/EventModel.dart';
import 'package:ecomed/Screens/Event/AddEvent.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class EventCalendar extends StatefulWidget {
  const EventCalendar({Key? key}) : super(key: key);

  @override
  State<EventCalendar> createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  final Map<DateTime, List<Event>> _events = {};

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _fetchAndSetEvents(_focusedDay.month, _focusedDay.year);
  }

  Future<void> _fetchAndSetEvents(int month, int year) async {
    try {
      final fetchedEvents =
          await ApiCalls.fetchEvents(month: month, year: year);
      final Map<DateTime, List<Event>> eventMap = {};

      for (var event in fetchedEvents) {
        DateTime parsedDate = DateTime.parse(event.date);
        final key =
            DateTime.utc(parsedDate.year, parsedDate.month, parsedDate.day);
        if (eventMap.containsKey(key)) {
          eventMap[key]!.add(event);
        } else {
          eventMap[key] = [event];
        }
      }

      setState(() {
        _events.clear();
        _events.addAll(eventMap);
      });
    } catch (e) {
      print('Error fetching events: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load events')),
      );
    }
  }

  Color _eventColor(String type) {
    switch (type) {
      case 'birthday':
        return Colors.pinkAccent;
      case 'meeting':
        return Colors.blueAccent;
      default:
        return Colors.green;
    }
  }

  IconData _eventIcon(String type) {
    switch (type) {
      case 'birthday':
        return Icons.cake;
      case 'meeting':
        return Icons.people;
      default:
        return Icons.event;
    }
  }

  void _showEventsDialog(List<Event> events) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Events",
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...events.map((event) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _eventColor(event.type), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(_eventIcon(event.type),
                        color: _eventColor(event.type)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title,
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(event.time,
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(
                        event.type.toUpperCase(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: _eventColor(event.type),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showAddEventSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Add Event functionality coming soon!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Event Calendar", style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TableCalendar<Event>(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2026, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.orange.shade300,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.indigo,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                final events = _getEventsForDay(selectedDay);
                _showEventsDialog(events);
              },

              // ✅ Add this below onDaySelected
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _fetchAndSetEvents(focusedDay.month, focusedDay.year);
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _selectedDay != null &&
                      _getEventsForDay(_selectedDay!).isNotEmpty
                  ? ListView.builder(
                      itemCount: _getEventsForDay(_selectedDay!).length,
                      itemBuilder: (_, index) {
                        final event = _getEventsForDay(_selectedDay!)[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _eventColor(event.type),
                            child: Icon(_eventIcon(event.type),
                                color: Colors.white),
                          ),
                          title: Text(event.title,
                              style: GoogleFonts.poppins(fontSize: 16)),
                          subtitle: Text(event.time),
                          trailing: Text(
                            event.type.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _eventColor(event.type),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No events for selected day",
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
        tooltip: 'Add Event',
        onPressed: () async {
          if (_selectedDay == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please select a date first")),
            );
            return;
          }

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEventPage(selectedDate: _selectedDay!),
            ),
          );

          // 🔄 Re-fetch events after returning from AddEventPage
          if (result == true) {
            _fetchAndSetEvents(_selectedDay!.month, _selectedDay!.year);
          }
        },
      ),
    );
  }
}
