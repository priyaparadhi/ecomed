class Company {
  final int companyId;
  final String companyName;
  final String? city;
  final String? createdBy;

  Company({
    required this.companyId,
    required this.companyName,
    this.city,
    this.createdBy,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyId: json['company_id'],
      companyName: json['company_name'] ?? 'Unnamed',
      city: json['city'],
      createdBy: json['created_by_string'],
    );
  }
}
