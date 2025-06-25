import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';
import '../widgets/homely_scaffold.dart';
import '../serviceprovider/service_details_screen.dart';
import '../services/review_service.dart';

class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({super.key});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
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

  @override
  Widget build(BuildContext context) {
    return HomelyScaffold(
      selectedIndex: 1,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'All Services',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase().trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search services...',
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
                ],
              ),
            ),

            // Services Grid Section
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
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

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading services',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_center_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No services available',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;
                  final filteredDocs = _filterServices(docs);

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No services found for "$_searchQuery"',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85, // Slightly taller cards
                          ),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final data =
                            filteredDocs[index].data() as Map<String, dynamic>;
                        final serviceId = filteredDocs[index].id;
                        final providerId = data['provider_id'] ?? '';

                        return _buildServiceCard(
                          context,
                          data,
                          serviceId,
                          providerId,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    Map<String, dynamic> data,
    String serviceId,
    String providerId,
  ) {
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
      child: Card(
        color: AppColors.background,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Service Image/Icon
              Container(
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.business_center,
                  size: 35,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),

              // Service Name
              Text(
                data['name'] ?? 'Service Name',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),

              // Category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.highlight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data['category'] ?? 'General',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.highlight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Description
              Text(
                data['description'] ?? '',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),

              // Rating and Price Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Dynamic reviews display
                  Flexible(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: ReviewService.getServiceRatingStats(serviceId),
                      builder: (context, reviewSnapshot) {
                        if (reviewSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 16,
                            child: Text(
                              'Loading...',
                              style: TextStyle(fontSize: 9, color: Colors.grey),
                            ),
                          );
                        }

                        if (!reviewSnapshot.hasData) {
                          return const Text(
                            'No reviews',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                          );
                        }

                        final stats = reviewSnapshot.data!;
                        final averageRating = stats['averageRating'] as double;
                        final totalReviews = stats['totalReviews'] as int;

                        if (totalReviews == 0) {
                          return const Text(
                            'No reviews',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < averageRating.floor()
                                      ? Icons.star
                                      : (index < averageRating &&
                                          averageRating % 1 >= 0.5)
                                      ? Icons.star_half
                                      : Icons.star_border,
                                  color: AppColors.highlight,
                                  size: 11,
                                );
                              }),
                            ),
                            Text(
                              '($totalReviews)',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Price
                  Text(
                    'RM${(data['hourly_rate'] ?? 0).toString()}',
                    style: const TextStyle(
                      color: AppColors.highlight,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
