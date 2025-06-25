import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login_screen.dart';
import '../home_screen.dart';
import '../screens/all_services_screen.dart';
import '../appointments/current_appointments_screen.dart';
import '../appointments/recent_appointments_screen.dart';
import '../appointments/provider_pending_appointments_screen.dart';
import '../appointments/provider_recent_appointments_screen.dart';
import '../serviceprovider/provider_services_reviews_screen.dart';
import '../theme/colors.dart';

typedef NavBarBuilder = Widget Function(BuildContext context);

class HomelyScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final bool showLogout;
  final VoidCallback? onLogout;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  const HomelyScaffold({
    super.key,
    required this.body,
    this.selectedIndex = 0,
    this.showLogout = true,
    this.onLogout,
    this.appBar,
    this.floatingActionButton,
  });

  Future<Map<String, dynamic>?> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc =
        await FirebaseFirestore.instance
            .collection('user_data')
            .doc(user.uid)
            .get();
    return doc.data();
  }

  void _onNavBarTap(BuildContext context, int index, bool isProvider) async {
    if (isProvider) {
      // Provider navigation mapping: 0=home, 1=calendar, 2=history, 3=reviews
      if (index == selectedIndex) return;

      if (index == 0) {
        // Home
        Navigator.pushReplacementNamed(context, '/serviceProviderDashboard');
      } else if (index == 1) {
        // Calendar (provider pending appointments)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProviderPendingAppointmentsPage(),
          ),
        );
      } else if (index == 2) {
        // History (provider recent appointments)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProviderRecentAppointmentsPage(),
          ),
        );
      } else if (index == 3) {
        // Reviews (provider services reviews)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProviderServicesReviewsScreen(),
          ),
        );
      }
    } else {
      // Homeowner navigation: 0=home, 1=menu, 2=calendar, 3=history
      if (index == selectedIndex) return;

      if (index == 0) {
        // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (index == 1) {
        // Menu (All Services) - only for homeowners
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AllServicesScreen()),
        );
      } else if (index == 2) {
        // Calendar (current appointments)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CurrentAppointmentsPage()),
        );
      } else if (index == 3) {
        // History (recent appointments)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RecentAppointmentsPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchUserData(),
      builder: (context, userSnapshot) {
        final userInfo = userSnapshot.data ?? {};
        final isProvider = userInfo['isProvider'] == true;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar:
              appBar ??
              AppBar(
                backgroundColor: AppColors.primary,
                title: const Text(
                  "Homely",
                  style: TextStyle(color: AppColors.background),
                ),
                actions:
                    showLogout
                        ? [
                          IconButton(
                            icon: const Icon(
                              Icons.logout,
                              color: AppColors.highlight,
                            ),
                            onPressed:
                                onLogout ??
                                () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                          ),
                        ]
                        : null,
              ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex:
                isProvider ? selectedIndex : selectedIndex,
            onTap: (i) => _onNavBarTap(context, i, isProvider),
            selectedItemColor: AppColors.highlight,
            unselectedItemColor: AppColors.primary,
            backgroundColor: AppColors.background,
            items: _getBottomNavItems(isProvider),
          ),
          floatingActionButton: floatingActionButton,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Address\n${userInfo['address'] ?? '-'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'Welcome, ${userInfo['name'] ?? '-'}!',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }

  // Get appropriate bottom nav items based on user type
  List<BottomNavigationBarItem> _getBottomNavItems(bool isProvider) {
    if (isProvider) {
      // Service providers: home, calendar, history, reviews (4 items)
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.star), label: ''),
      ];
    } else {
      // Homeowners: home, menu (all services), calendar, history (4 items)
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
      ];
    }
  }
}
