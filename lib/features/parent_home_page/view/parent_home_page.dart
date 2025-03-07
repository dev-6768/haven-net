import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:haven_net/features/first_screen/view/first_screen.dart';
import 'package:haven_net/features/parent_home_page/view/widget/complaints_list_widget.dart';
import 'package:haven_net/features/parent_home_page/view/widget/parent_blog_page_widget.dart';
import 'package:haven_net/features/parent_home_page/view/widget/parents_connect_page.dart';
import 'package:haven_net/features/parent_home_page/view/widget/tips_and_tricks_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentsHomePage extends StatefulWidget {
  final String email;
  const ParentsHomePage({super.key, required this.email});


  @override
  State<ParentsHomePage> createState() => _ParentsHomePageState();
}

class _ParentsHomePageState extends State<ParentsHomePage> {
  @override
  void dispose() {
    super.dispose();
    FirebaseAuth.instance.signOut();
  }

  Future<void> logoutParentUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_email', "");
    await prefs.setString('login_password', "");
    await prefs.setString('login_user_type', "");

    Navigator.pop(context);
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FirstScreen())
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Welcome, Parents!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.pink.shade300,
          actions: [
            TextButton(
              onPressed: () async {
                await logoutParentUser();
              },
              child: const Text("Logout"),
            ),
          ],
        ),
        body: ParentHomePageBody(email: widget.email),

        // bottomNavigationBar: BottomNavigationBar(
        //   items: const [
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.home),
        //       label: 'Home',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.favorite),
        //       label: 'Favorites',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.settings),
        //       label: 'Settings',
        //     ),
        //   ],
        //   selectedItemColor: Colors.pink.shade300,
        // ),
      );
  }
}

class ParentHomePageBody extends StatelessWidget {
  final String email;
  const ParentHomePageBody({super.key, required this.email});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hero Banner
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.pink.shade200, Colors.pink.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              height: 200,
              width: double.infinity,
              child: const Center(
                child: Text(
                  'Parenthood: Love, Care, and Growth',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Motivational Quote Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '"Parenting is the greatest act of love one can offer."',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // List Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Helpful Resources',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.note, color: Colors.pink.shade300),
                  title: const Text('View Complaints'),
                  subtitle: const Text('View your child complaints'),
                  trailing: IconButton(onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) {
                          return ComplaintsPage(parentEmail: email, userType: "parent");
                        }
                      )
                    );
                  }, icon: const Icon(Icons.arrow_forward_ios)),
                ),

                ListTile(
                  leading: Icon(Icons.book, color: Colors.pink.shade300),
                  title: const Text('Parenting Guide'),
                  subtitle: const Text('Learn the best practices for parenting.'),
                  trailing: IconButton(onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BlogSearchPage())
                    );
                  }, icon: const Icon(Icons.arrow_forward_ios),)
                ),

                ListTile(
                  leading: Icon(Icons.lightbulb, color: Colors.pink.shade300),
                  title: const Text('Tips & Tricks'),
                  subtitle: const Text('Quick advice for daily challenges.'),
                  trailing: IconButton(onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TipsAndTricksWidget(email: email)
                      )
                    );
                  }, icon: const Icon(Icons.arrow_forward_ios),)
                ),
                ListTile(
                  leading: Icon(Icons.support, color: Colors.pink.shade300),
                  title: const Text('Support Groups'),
                  subtitle: const Text('Connect with other parents.'),
                  trailing: IconButton(onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) {
                          return const ComplaintSearchPage();
                        }
                      )
                    );
                  }, icon: const Icon(Icons.arrow_forward_ios),)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // A helper method to create icon buttons
  Widget _iconCard(IconData icon, String label) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.pink.shade100,
          ),
          padding: const EdgeInsets.all(16),
          child: Icon(
            icon,
            size: 30,
            color: Colors.pink.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
