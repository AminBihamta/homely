import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login_screen.dart';
import '../home_screen.dart';
import '../appointments/current_appointments_screen.dart';
import '../appointments/recent_appointments_screen.dart';
import '../appointments/provider_pending_appointments_screen.dart';
import '../appointments/provider_recent_appointments_screen.dart';
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

  void _onNavBarTap(BuildContext context, int index) async {
    if (index == selectedIndex) return;
    if (index == 0) {
      // Check if user is provider
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc =
            await FirebaseFirestore.instance
                .collection('user_data')
                .doc(user.uid)
                .get();
        final data = doc.data() ?? {};
        final isProvider = data['isProvider'] == true;
        if (isProvider) {
          Navigator.pushReplacementNamed(context, '/serviceProviderDashboard');
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        // fallback: go to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else if (index == 2) {
      // Check if user is provider
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc =
            await FirebaseFirestore.instance
                .collection('user_data')
                .doc(user.uid)
                .get();
        final data = doc.data() ?? {};
        final isProvider = data['isProvider'] == true;
        if (isProvider) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ProviderPendingAppointmentsPage(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CurrentAppointmentsPage()),
          );
        }
      } else {
        // fallback: go to current appointments
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CurrentAppointmentsPage()),
        );
      }
    } else if (index == 3) {
      // Check if user is provider
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc =
            await FirebaseFirestore.instance
                .collection('user_data')
                .doc(user.uid)
                .get();
        final data = doc.data() ?? {};
        final isProvider = data['isProvider'] == true;
        if (isProvider) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ProviderRecentAppointmentsPage(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RecentAppointmentsPage()),
          );
        }
      } else {
        // fallback: go to homeowner recent appointments
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RecentAppointmentsPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        currentIndex: selectedIndex,
        onTap: (i) => _onNavBarTap(context, i),
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
      floatingActionButton: floatingActionButton,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: fetchUserData(),
            builder: (context, snapshot) {
              final userInfo = snapshot.data ?? {};
              final address = userInfo['address'] ?? '-';
              final name = userInfo['name'] ?? '-';

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                        'Welcome, $name!',
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
          Expanded(child: body),
        ],
      ),
    );
  }
}
