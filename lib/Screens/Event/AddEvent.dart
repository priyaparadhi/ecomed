import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:flutter/material.dart';

class AddEventPage extends StatefulWidget {
  final DateTime selectedDate;

  const AddEventPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController eventTitle = TextEditingController();
  final TextEditingController eventDescription = TextEditingController();
  String _type = 'meeting';
  TimeOfDay? _time;
  DateTime? _eventDate;
  List<Map<String, dynamic>> _eventTypes = [];
  int? _selectedEventTypeId;

  @override
  void initState() {
    super.initState();
    _loadEventTypes();
    _eventDate = widget.selectedDate;
  }

  void _submit() async {
    if (_formKey.currentState!.validate() &&
        _time != null &&
        _eventDate != null &&
        _selectedEventTypeId != null) {
      _formKey.currentState!.save();

      final formattedTime =
          '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}:00';
      final formattedDate =
          '${_eventDate!.year}-${_eventDate!.month.toString().padLeft(2, '0')}-${_eventDate!.day.toString().padLeft(2, '0')}';

      try {
        final response = await ApiCalls.addEvent(
          eventTypeId: _selectedEventTypeId!,
          eventTitle: eventTitle.text.trim(),
          eventDescription: eventDescription.text.trim(),
          eventDate: formattedDate,
          eventTime: formattedTime,
        );

        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response['message'] ?? 'Failed to add event')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
    }
  }

  void _loadEventTypes() async {
    try {
      final types = await ApiCalls.fetchEventTypes();
      setState(() {
        _eventTypes = types;
        if (_eventTypes.isNotEmpty) {
          _selectedEventTypeId = _eventTypes.first['event_type_id'];
        }
      });
    } catch (e) {
      print('Error loading event types: $e');
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
      backgroundColor: const Color(0xFFF2F5F9),
      appBar: AppBar(
        title: const Text("Add Event",
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Event Details",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 30),

                // Event Title
                TextFormField(
                  decoration: _inputDecoration("Event Title", Icons.title),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter event title' : null,
                  onSaved: (value) => eventTitle.text = value!.trim(),
                ),
                const SizedBox(height: 24),

                // Event Description
                TextFormField(
                  decoration:
                      _inputDecoration("Event Description", Icons.description),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter event description' : null,
                  onSaved: (value) => eventDescription.text = value!.trim(),
                  maxLines: 5,
                ),
                const SizedBox(height: 24),

                // Event Type Dropdown
                _eventTypes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<int>(
                        value: _selectedEventTypeId,
                        decoration: _inputDecoration(
                            "Event Type", Icons.category_outlined),
                        items: _eventTypes.map((type) {
                          return DropdownMenuItem<int>(
                            value: type['event_type_id'],
                            child: Text(type['event_type']),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedEventTypeId = val),
                      ),

                const SizedBox(height: 24),

                // Date Picker
                _pickerTile(
                  icon: Icons.calendar_today_outlined,
                  label: _eventDate == null
                      ? 'Pick a date'
                      : '${_eventDate!.day}-${_eventDate!.month}-${_eventDate!.year}',
                  onTap: _pickDate,
                ),

                const SizedBox(height: 16),

                // Time Picker
                _pickerTile(
                  icon: Icons.access_time_outlined,
                  label: _time == null ? 'Pick a time' : _time!.format(context),
                  onTap: _pickTime,
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Save Event",
                        style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.indigo, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
    );
  }

  Widget _pickerTile(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      tileColor: Colors.grey.shade100,
      leading: Icon(icon, color: Colors.indigo),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing: TextButton(
        onPressed: onTap,
        child:
            const Text("Select", style: TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }
}
