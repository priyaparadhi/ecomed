import 'package:ecomed/ApiCalls/ApiCalls.dart';
import 'package:ecomed/Models/ContactModel.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;
  String _error = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchContacts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        final name = '${contact.firstName ?? ''} ${contact.lastName ?? ''}'
            .toLowerCase();
        final email = contact.email?.toLowerCase() ?? '';
        final mob = contact.mobNo?.toString() ?? '';
        final company = contact.companyName?.toLowerCase() ?? '';
        return name.contains(query) ||
            email.contains(query) ||
            mob.contains(query) ||
            company.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchContacts() async {
    try {
      final contacts = await ApiCalls.fetchContacts();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _filteredContacts = contacts;
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

  Widget _buildContactCard(Contact contact) {
    final fullName =
        "${contact.firstName ?? ''} ${contact.lastName ?? ''}".trim();
    final String initials = (contact.firstName?.isNotEmpty ?? false)
        ? contact.firstName![0].toUpperCase()
        : "?";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Add contact detail popup or nav here
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.indigo.shade100,
                  child: Text(
                    initials,
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
                        fullName.isNotEmpty ? fullName : "Unnamed Contact",
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (contact.email != null && contact.email!.isNotEmpty)
                        Text("📧 ${contact.email!}", style: _infoStyle()),
                      if (contact.mobNo != null)
                        Text("📱 ${contact.mobNo}", style: _infoStyle()),
                      if (contact.designation != null &&
                          contact.designation!.isNotEmpty)
                        Text("💼 ${contact.designation!}", style: _infoStyle()),
                      const SizedBox(height: 6),
                      if (contact.companyName != null &&
                          contact.companyName!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            contact.companyName!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.indigo,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _infoStyle() {
    return const TextStyle(
      fontSize: 13.5,
      color: Colors.black54,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text("Contacts"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1.5,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search contact...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(child: Text("Error: $_error"))
                    : _filteredContacts.isEmpty
                        ? const Center(child: Text("No contacts found."))
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20, top: 8),
                            itemCount: _filteredContacts.length,
                            itemBuilder: (context, index) =>
                                _buildContactCard(_filteredContacts[index]),
                          ),
          ),
        ],
      ),
    );
  }
}
