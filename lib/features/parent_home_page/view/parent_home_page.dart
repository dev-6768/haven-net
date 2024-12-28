import 'package:flutter/material.dart';

class ParentsHomePage extends StatelessWidget {
  const ParentsHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Welcome, Parents!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.pink.shade300,
        ),
        body: ParentHomePageBody(),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          selectedItemColor: Colors.pink.shade300,
        ),
      ),
    );
  }
}

class ParentHomePageBody extends StatelessWidget {
  const ParentHomePageBody({super.key});
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

            // Icon Buttons Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _iconCard(Icons.family_restroom, 'Family Time'),
                _iconCard(Icons.child_friendly, 'Child Care'),
                _iconCard(Icons.school, 'Education'),
              ],
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
                  leading: Icon(Icons.book, color: Colors.pink.shade300),
                  title: const Text('Parenting Guide'),
                  subtitle: const Text('Learn the best practices for parenting.'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  leading: Icon(Icons.lightbulb, color: Colors.pink.shade300),
                  title: const Text('Tips & Tricks'),
                  subtitle: const Text('Quick advice for daily challenges.'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  leading: Icon(Icons.support, color: Colors.pink.shade300),
                  title: const Text('Support Groups'),
                  subtitle: const Text('Connect with other parents.'),
                  trailing: const Icon(Icons.arrow_forward_ios),
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
