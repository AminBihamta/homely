import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/review_service.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter services based on search query
  List<QueryDocumentSnapshot> _filterServices(
    List<QueryDocumentSnapshot> docs,
  ) {
    if (_searchQuery.isEmpty) {
      return docs;
    }

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final serviceName = (data['name'] ?? '').toString().toLowerCase();
      final serviceDescription =
          (data['description'] ?? '').toString().toLowerCase();
      final serviceCategory = (data['category'] ?? '').toString().toLowerCase();

      return serviceName.contains(_searchQuery) ||
          serviceDescription.contains(_searchQuery) ||
          serviceCategory.contains(_searchQuery);
    }).toList();
  }

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
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase().trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'What service do you need?',
                    hintStyle: const TextStyle(color: AppColors.text),
                    prefixIcon: const Icon(
                      Icons.search,
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
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = cat;
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? '$selectedCategory Services For You'
                      : 'Search Results',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  _searchQuery.isEmpty
                      ? 'Our recommended services based on your preference'
                      : 'Services matching "$_searchQuery"',
                  style: const TextStyle(color: AppColors.text),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height:
                      235, // Increased height to accommodate dynamic content
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        _searchQuery.isEmpty
                            ? FirebaseFirestore.instance
                                .collection('services')
                                .where('category', isEqualTo: selectedCategory)
                                .snapshots()
                            : FirebaseFirestore.instance
                                .collection('services')
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
                      final filteredDocs = _filterServices(docs);

                      if (filteredDocs.isEmpty) {
                        return Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'No services available'
                                : 'No services found for "$_searchQuery"',
                            style: const TextStyle(color: AppColors.text),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final data =
                              filteredDocs[index].data()
                                  as Map<String, dynamic>;
                          final serviceId = filteredDocs[index].id;
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
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              width: 180,
                              margin: const EdgeInsets.only(
                                right: 12,
                                bottom: 4,
                                top: 4,
                              ), // Increased vertical margin for breathing room
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
                                    8,
                                  ), // Consistent padding
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height:
                                            85, // Slightly reduced image height
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.image,
                                          size: 40,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ), // Further reduced spacing
                                      Text(
                                        data['name'] ?? 'Service Name',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.text,
                                          fontSize: 14, // Slightly smaller font
                                        ),
                                        maxLines: 4,
                                        overflow: TextOverflow.visible,
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ), // Further reduced spacing
                                      // Dynamic reviews display
                                      FutureBuilder<Map<String, dynamic>>(
                                        future:
                                            ReviewService.getServiceRatingStats(
                                              serviceId,
                                            ),
                                        builder: (context, reviewSnapshot) {
                                          if (reviewSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const SizedBox(
                                              height:
                                                  18, // Slightly reduced height
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 12,
                                                    height: 12,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 1,
                                                        ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Loading...',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

                                          if (!reviewSnapshot.hasData) {
                                            return const SizedBox(
                                              height: 18, // Consistent height
                                              child: Text(
                                                'No reviews yet',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            );
                                          }

                                          final stats = reviewSnapshot.data!;
                                          final averageRating =
                                              stats['averageRating'] as double;
                                          final totalReviews =
                                              stats['totalReviews'] as int;

                                          if (totalReviews == 0) {
                                            return const SizedBox(
                                              height: 18, // Consistent height
                                              child: Text(
                                                'No reviews yet',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            );
                                          }

                                          return SizedBox(
                                            height: 18, // Consistent height
                                            child: Row(
                                              children: [
                                                // Star rating display
                                                Row(
                                                  children: List.generate(5, (
                                                    index,
                                                  ) {
                                                    return Icon(
                                                      index <
                                                              averageRating
                                                                  .floor()
                                                          ? Icons.star
                                                          : (index <
                                                                  averageRating &&
                                                              averageRating %
                                                                      1 >=
                                                                  0.5)
                                                          ? Icons.star_half
                                                          : Icons.star_border,
                                                      color:
                                                          AppColors.highlight,
                                                      size:
                                                          14, // Smaller star size
                                                    );
                                                  }),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '($totalReviews)',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ), // Further reduced spacing
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
                                            minimumSize: const Size(
                                              0,
                                              32,
                                            ), // Slightly smaller button
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
                                              fontSize: 13, // Smaller font size
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
