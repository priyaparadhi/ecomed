import 'package:flutter/material.dart';

class Event {
  final String title;
  final String type;
  final String time;

  Event({required this.title, required this.type, required this.time});
}

class AddEventPage extends StatefulWidget {
  final DateTime selectedDate;

  const AddEventPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _type = 'meeting';
  TimeOfDay? _time;
  DateTime? _eventDate;

  final List<String> _types = ['birthday', 'meeting', 'other'];

  @override
  void initState() {
    super.initState();
    _eventDate = widget.selectedDate;
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        _time != null &&
        _eventDate != null) {
      _formKey.currentState!.save();
      final formattedTime =
          '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';
      final newEvent = Event(title: _title, type: _type, time: formattedTime);
      Navigator.pop(context, {'event': newEvent, 'date': _eventDate});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
    }
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Add Event",
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Event Details",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 24),

                // Event Title
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Event Title",
                    prefixIcon: const Icon(Icons.title),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter event title' : null,
                  onSaved: (value) => _title = value!.trim(),
                ),

                const SizedBox(height: 20),

                // Event Type
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: InputDecoration(
                    labelText: "Event Type",
                    prefixIcon: const Icon(Icons.category_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _types
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _type = val!),
                ),

                const SizedBox(height: 20),

                // Date Picker
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.grey.shade100,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(
                    _eventDate == null
                        ? 'Pick a date'
                        : '${_eventDate!.day}-${_eventDate!.month}-${_eventDate!.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: TextButton(
                    onPressed: _pickDate,
                    child: const Text("Select"),
                  ),
                ),

                const SizedBox(height: 16),

                // Time Picker
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.grey.shade100,
                  leading: const Icon(Icons.access_time_outlined),
                  title: Text(
                    _time == null ? 'Pick a time' : _time!.format(context),
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: TextButton(
                    onPressed: _pickTime,
                    child: const Text("Select"),
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text(
                      "Save Event",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
