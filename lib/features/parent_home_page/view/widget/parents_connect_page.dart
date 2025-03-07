import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ComplaintSearchPage extends StatefulWidget {
  const ComplaintSearchPage({super.key});
  @override
  _ComplaintSearchPageState createState() => _ComplaintSearchPageState();
}

class _ComplaintSearchPageState extends State<ComplaintSearchPage> {
  final List<String> _complaintTypes = [
    "School Punishment",
    "Harassment",
    "Hate Crime",
    "Battery",
    "Assault",
    "Physical Harm",
    "Cyberbullying",
    "Kidnapping",
    "Abuse",
    "Child Labor",
    "Child Trafficking",
    "Child Begging",
  ];

  String _selectedType = "Harassment"; // Default selection
  final ValueNotifier<List<QueryDocumentSnapshot>> _complaintsNotifier =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _fetchComplaints(); // Fetch complaints for default selection
  }

  Future<void> _fetchComplaints() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('complaints')
        .get();

    // Filter complaints where selected type is a substring in 'legal_repercussions'
    List<QueryDocumentSnapshot> filteredComplaints = snapshot.docs.where((doc) {
      String legalRepercussions = (doc['legal_reprecussions'] as String).toLowerCase();
      return legalRepercussions.contains(_selectedType.toLowerCase());
    }).toList();

    _complaintsNotifier.value = filteredComplaints;
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Complaints")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown to select complaint type
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _complaintTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedType = newValue!;
                });
                _fetchComplaints();
              },
              decoration: const InputDecoration(
                labelText: "Select Complaint Type",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // List of complaints
            Expanded(
              child: ValueListenableBuilder<List<QueryDocumentSnapshot>>(
                valueListenable: _complaintsNotifier,
                builder: (context, complaints, child) {
                  return complaints.isEmpty
                      ? const Center(child: Text("No complaints found"))
                      : ListView.builder(
                          itemCount: complaints.length,
                          itemBuilder: (context, index) {
                            var complaint = complaints[index].data() as Map<String, dynamic>;
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Subject: ${complaint['complaint_subject']}",
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Time: ${_formatTimestamp(complaint['complaint_time'])}",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Details: ${complaint['complaint_body']}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const Divider(),
                                    Text(
                                      "Victim Name: ${complaint['victim_name']}",
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text("Grade: ${complaint['victim_grade']}"),
                                    Text("Location: ${complaint['victim_location']}"),
                                    const Divider(),
                                    const Text(
                                      "Parent Contacts:",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text("Father Email: ${complaint['victim_father_email']}"),
                                    Text("Mother Email: ${complaint['victim_mother_email']}"),
                                    Text("Father Phone Contact: ${complaint['victim_father_contact']}"),
                                    Text("Mother Phone Contact: ${complaint['victim_mother_contact']}"),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
