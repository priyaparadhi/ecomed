class Event {
  final int eventId;
  final int eventTypeId;
  final String title;
  final String date; // Keep as String for parsing
  final String time;
  final String type;
  final String description;
  final int createdBy;
  final String createdByName;

  Event({
    required this.eventId,
    required this.eventTypeId,
    required this.title,
    required this.date,
    required this.time,
    required this.type,
    required this.description,
    required this.createdBy,
    required this.createdByName,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'],
      eventTypeId: json['event_type_id'],
      title: json['event_title'],
      date: json['event_date'],
      time: json['event_time'],
      type: json['event_type_name'].toLowerCase(),
      description: json['event_description'],
      createdBy: json['created_by'],
      createdByName: json['created_by_name'],
    );
  }
}
