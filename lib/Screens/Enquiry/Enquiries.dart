import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Models/EnquiryModel.dart';
import 'package:ecomed/Screens/Enquiry/AddEnquiry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnquiryPage extends StatefulWidget {
  const EnquiryPage({super.key});

  @override
  State<EnquiryPage> createState() => _EnquiryPageState();
}

class _EnquiryPageState extends State<EnquiryPage> {
  List<Enquiry> _enquiries = [];
  List<Enquiry> _filteredEnquiries = [];
  bool _isLoading = true;
  String _error = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEnquiries();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEnquiries = _enquiries.where((e) {
        final fullName = "${e.firstName} ${e.lastName}".toLowerCase().trim();
        final company = e.companyName?.toLowerCase() ?? '';
        return fullName.contains(query) || company.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchEnquiries() async {
    try {
      final data = await ApiCalls.fetchEnquiries();
      if (!mounted) return;
      setState(() {
        _enquiries = data;
        _filteredEnquiries = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty || rawDate == '0000-00-00')
      return '';
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return '';
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.indigo),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnquiryCard(Enquiry enquiry) {
    final fullName = '${enquiry.firstName} ${enquiry.lastName}'.trim();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.indigo.withOpacity(0.1),
                child: Text(
                  fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      enquiry.email,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _detailRow(Icons.business, "Company", enquiry.companyName),
          _detailRow(Icons.phone_android, "Mobile", enquiry.mobNo.toString()),
          _detailRow(
              Icons.timeline, "Timeline", enquiry.purchaseTimeline ?? ""),
          _detailRow(Icons.note_alt_outlined, "Note", enquiry.note ?? ""),
          _detailRow(
              Icons.calendar_month, "Created", _formatDate(enquiry.createdAt)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    if (value.isEmpty || value == 'null') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.indigo, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        title: const Text("Enquiries"),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Error: $_error",
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search by name or company",
                          prefixIcon: const Icon(Icons.search),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _filteredEnquiries.isEmpty
                          ? const Center(
                              child: Text(
                                "No matching enquiries found.",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black54),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchEnquiries,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(
                                    bottom: 20, left: 10, right: 10, top: 4),
                                physics: const BouncingScrollPhysics(),
                                itemCount: _filteredEnquiries.length,
                                itemBuilder: (context, index) =>
                                    _buildEnquiryCard(
                                        _filteredEnquiries[index]),
                              ),
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEnquiryForm()),
          );
        },
      ),
    );
  }
}
