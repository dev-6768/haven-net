import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haven_net/features/parent_home_page/view/widget/write_blog_page.dart';
import 'package:intl/intl.dart';

class BlogSearchPage extends StatefulWidget {
  const BlogSearchPage({super.key});
  @override
  _BlogSearchPageState createState() => _BlogSearchPageState();
}

class _BlogSearchPageState extends State<BlogSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<List<QueryDocumentSnapshot>> _blogsNotifier =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchBlogs);
    _fetchAllBlogs();
  }

  Future<void> _fetchAllBlogs() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('blogs').get();
    _blogsNotifier.value = snapshot.docs;
  }

  Future<void> _searchBlogs() async {
    String query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      _fetchAllBlogs();
      return;
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('blogs')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: query + 'z')
        //.orderBy('time', descending: true)
        .get();

    _blogsNotifier.value = snapshot.docs;
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Blogs")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WriteBlogPage())
          );
        },
        child: const Icon(Icons.add)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Search by Title",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<List<QueryDocumentSnapshot>>(
                valueListenable: _blogsNotifier,
                builder: (context, blogs, child) {
                  return blogs.isEmpty
                      ? const Center(child: Text("No blogs found"))
                      : ListView.builder(
                          itemCount: blogs.length,
                          itemBuilder: (context, index) {
                            var blog =
                                blogs[index].data() as Map<String, dynamic>;
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      blog['title'],
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "By: ${blog['author']} | ${_formatTimestamp(blog['time'])}",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      blog['body'],
                                      style: const TextStyle(fontSize: 14),
                                    ),
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
