import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WriteBlogPage extends StatelessWidget {
  const WriteBlogPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WriteBlogWidget(),
    );
  }
}

class WriteBlogWidget extends StatefulWidget {
  const WriteBlogWidget({super.key});
  @override
  _WriteBlogWidgetState createState() => _WriteBlogWidgetState();
}

class _WriteBlogWidgetState extends State<WriteBlogWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  Future<void> _getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString("login_email") ?? "anonymous@example.com";
    });
  }

  Future<void> _submitBlog() async {
    if (!_formKey.currentState!.validate()) return;

    String title = _titleController.text.trim();
    String body = _bodyController.text.trim();
    String author = _userEmail ?? "anonymous@example.com";
    Timestamp timestamp = Timestamp.now();

    try {
      await FirebaseFirestore.instance.collection('blogs').add({
        'author': author,
        'title': title,
        'body': body,
        'time': timestamp,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Blog Submitted Successfully!"), backgroundColor: Colors.green),
      );

      _titleController.clear();
      _bodyController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Blog")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Blog Title", border: OutlineInputBorder()),
                validator: (value) => value!.trim().isEmpty ? "Title cannot be empty" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: "Blog Content", border: OutlineInputBorder()),
                maxLines: 8,
                validator: (value) => value!.trim().isEmpty ? "Blog content cannot be empty" : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitBlog,
                  child: const Text("Submit Blog"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
