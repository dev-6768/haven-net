import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintsPage extends StatefulWidget {
  final String parentEmail;
  final String userType;

  const ComplaintsPage({super.key, required this.parentEmail, required this.userType});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complaints")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .where(Filter.or(
              Filter("victim_father_email", isEqualTo: widget.parentEmail),
              Filter("victim_mother_email", isEqualTo: widget.parentEmail),
            ))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No complaints found for ${widget.parentEmail}."));
          }

          var complaints = snapshot.data!.docs;

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              var data = complaints[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data["complaint_subject"] ?? "No Subject"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Victim: ${data["victim_name"] ?? "Unknown"}"),
                      Text("Grade: ${data["victim_grade"] ?? "N/A"}"),
                      Text("Time: ${data["complaint_time"].toDate()}"),
                      const SizedBox(height: 5),
                      Text(data["complaint_body"] ?? "No details available"),
                      if (data["legal_reprecussions"] != null)
                        Text("Legal: ${data["legal_reprecussions"]}"),
                      if (data["victim_location"] != null)
                        Text("Location: ${data["victim_location"]}"),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
