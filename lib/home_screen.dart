import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Electrical'; // Default category

  void logout(BuildContext context) {
    AuthService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  IconData getIconData(String iconName) {
    switch (iconName) {
      case 'bolt':
        return Icons.bolt;
      case 'plumbing':
        return Icons.plumbing;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'handyman':
        return Icons.handyman;
      default:
        return Icons.category; // default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homely"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => logout(context),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address and welcome
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Address\n8, Jalan Maktab',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Welcome, Maliha!',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Find Your Desired Service',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'What service do you need?',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.tune),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Categories
              const Text(
                'Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: FutureBuilder<QuerySnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('service_categories')
                          .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No categories found'));
                    }
                    final categories = snapshot.data!.docs;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final doc = categories[index];
                        final cat = doc.id;
                        final iconName = doc['icon'] as String? ?? 'category';
                        final isSelected = cat == selectedCategory;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            avatar: Icon(getIconData(iconName), size: 20),
                            label: Text(cat),
                            selected: isSelected,
                            onSelected:
                                (_) => setState(() => selectedCategory = cat),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Services title
              Text(
                '$selectedCategory Services For You',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('Our recommended services based on your preference'),
              const SizedBox(height: 10),

              // Services list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('services')
                          .where('category', isEqualTo: selectedCategory)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty)
                      return const Center(child: Text('No services available'));

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Placeholder image
                                Container(
                                  height: 100,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    color: Colors.grey[300],
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    data['name'] ?? 'Service Name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Row(
                                    children: List.generate(
                                      5,
                                      (i) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                    ),
                                  ),
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
      ),
    );
  }
}
