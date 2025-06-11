import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import 'theme/colors.dart';
import '../appointments/book_appointment_screen.dart';
import 'widgets/homely_scaffold.dart';
import '../serviceprovider/service_details_screen.dart';

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

    final doc =
        await FirebaseFirestore.instance.collection('user_data').doc(uid).get();

    if (!doc.exists) return null;

    final data = doc.data() ?? {};
    // Add fallback for missing fields
    data['name'] = data['name'] ?? '';
    data['address'] = data['address'] ?? '';
    return data;
  }

  ///commented out old navigation between screens
  // void _onNavBarTap(int index) {
  //   setState(() {
  //    // _selectedIndex = index;
  //   });
  //   if (index == 2) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (_) => const CurrentAppointmentsPage()),
  //     );
  //   } else if (index == 3) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (_) => const RecentAppointmentsPage()),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return HomelyScaffold(
      selectedIndex: 0,
      onLogout: () {
        AuthService.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    suffixIcon: const Icon(
                      Icons.tune,
                      color: AppColors.primary,
                    ),
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
                SizedBox(
                  height: 218, // Increased height to prevent overflow
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

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final serviceId = docs[index].id;
                          final providerId = data['provider_id'] ?? '';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ServiceDetailsScreen(
                                        serviceId: serviceId,
                                        serviceName: data['name'] ?? '',
                                        companyName: data['companyName'] ?? '',
                                        rating: data['rating'] ?? 4,
                                        totalReviews:
                                            data['totalReviews'] ?? 129,
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              width: 180,
                              margin: const EdgeInsets.only(
                                right: 12,
                                bottom: 2,
                                top: 2,
                              ), // reduced vertical margin
                              child: Card(
                                color: AppColors.background,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    8,
                                    8,
                                    4,
                                  ), // less bottom padding
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 90,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: AppColors.primary.withOpacity(
                                            0.1,
                                          ),
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
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => BookAppointmentPage(
                                                      serviceId: serviceId,
                                                      providerId: providerId,
                                                      serviceName:
                                                          data['name'] ?? '',
                                                    ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor:
                                                AppColors.background,
                                            minimumSize: const Size(0, 36),
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Book',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
      ),
    );
  }
}
