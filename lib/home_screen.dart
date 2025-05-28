import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import 'theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Electrical';

  void logout(BuildContext context) {
    AuthService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  IconData getMaterialIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'format_paint':
        return Icons.format_paint;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'hardware_rounded':
        return Icons.plumbing;
      case 'electrical_services':
        return Icons.electrical_services;
      default:
        return Icons.category;
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          "Homely",
          style: TextStyle(color: AppColors.background),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.highlight),
            onPressed: () => logout(context),
          ),
        ],
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: fetchUserData(),
                builder: (context, snapshot) {
                  final userInfo = snapshot.data ?? {};
                  final address = userInfo['Address'] ?? '-';
                  final username = userInfo['username'] ?? '';
                  final displayName =
                      username.isNotEmpty
                          ? '${username[0].toUpperCase()}${username.substring(1)}'
                          : 'User';

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Address\n$address',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            'Welcome, $displayName!',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
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

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No categories found',
                          style: TextStyle(color: AppColors.text),
                        ),
                      );
                    }

                    final categories = snapshot.data!.docs;
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final doc = categories[index];
                        final cat = doc.id;
                        final iconName =
                            (doc['icon'] as String?)?.trim() ?? 'category';
                        final isSelected = cat == selectedCategory;

                        return ChoiceChip(
                          avatar: Icon(
                            getMaterialIcon(iconName),
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
                          showCheckmark: false, // <-- Add this line
                          onSelected:
                              (_) => setState(() => selectedCategory = cat),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
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
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('services')
                          .where('category', isEqualTo: selectedCategory)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No services available',
                          style: TextStyle(color: AppColors.text),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return Container(
                          width: 180,
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Card(
                            color: AppColors.background,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 90,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: AppColors.primary.withOpacity(0.1),
                                    ),
                                    child: const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    data['name'] ?? 'Service Name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.text,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (_) => const Icon(
                                        Icons.star,
                                        color: AppColors.highlight,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: Text(
                                      data['description'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.text,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
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
