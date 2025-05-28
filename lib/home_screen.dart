import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/colors.dart';

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

  Future<Map<String, dynamic>?> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final uid = user.uid;
    final email = user.email ?? '';
    final username = email.split('@').first;
    final doc =
        await FirebaseFirestore.instance.collection('user_data').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data() ?? {};
    data['username'] = username;
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          "Homely",
          style: TextStyle(color: AppColors.background),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.highlight),
            tooltip: 'Logout',
            onPressed: () => logout(context),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.highlight,
        unselectedItemColor: AppColors.primary,
        backgroundColor: AppColors.background,
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
              FutureBuilder<Map<String, dynamic>?>(
                future: fetchUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Address\n...',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          'Welcome, ...',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    );
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Address\n-',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          'Welcome!',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    );
                  }
                  final data = snapshot.data!;
                  final address = data['Address'] ?? '-'; // Capital A
                  final username = data['username'] ?? '';
                  final displayName =
                      username.isNotEmpty
                          ? '${username[0].toUpperCase()}${username.substring(1)}'
                          : '';
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Address\n$address',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        'Welcome, $displayName!',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Find Your Desired Service',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 10),

              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'What service do you need?',
                  hintStyle: const TextStyle(color: AppColors.text),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                  ),
                  suffixIcon: const Icon(Icons.tune, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.highlight,
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 16),

              // Categories
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
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
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: AppColors.text),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No categories found',
                          style: TextStyle(color: AppColors.text),
                        ),
                      );
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
                            avatar: Icon(
                              getIconData(iconName),
                              size: 20,
                              color:
                                  isSelected
                                      ? AppColors.background
                                      : AppColors.primary,
                            ),
                            label: Text(
                              cat,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? AppColors.background
                                        : AppColors.primary,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.highlight,
                            backgroundColor: AppColors.background,
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
                  color: AppColors.text,
                ),
              ),
              const Text(
                'Our recommended services based on your preference',
                style: TextStyle(color: AppColors.text),
              ),
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
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No services available',
                          style: TextStyle(color: AppColors.text),
                        ),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12),
                          child: Card(
                            color: AppColors.background,
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
                                    color: AppColors.primary.withOpacity(0.1),
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    data['name'] ?? 'Service Name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.text,
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
                                        color: AppColors.highlight,
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
