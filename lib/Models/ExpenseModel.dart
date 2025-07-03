class ExpenseEntry {
  final String date;
  final String from;
  final String to;
  final String workDescription;
  final double distanceKm;
  final double fare;
  final int bus;
  final int train;
  final int bike;
  final int auto;
  final bool hasPhysicalBill;
  final double food;
  final double total;

  ExpenseEntry({
    required this.date,
    required this.from,
    required this.to,
    required this.workDescription,
    required this.distanceKm,
    required this.fare,
    required this.bus,
    required this.train,
    required this.bike,
    required this.auto,
    required this.hasPhysicalBill,
    required this.food,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'from': from,
        'to': to,
        'workDescription': workDescription,
        'distanceKm': distanceKm,
        'fare': fare,
        'bus': bus,
        'train': train,
        'bike': bike,
        'auto': auto,
        'hasPhysicalBill': hasPhysicalBill,
        'food': food,
        'total': total,
      };
}
