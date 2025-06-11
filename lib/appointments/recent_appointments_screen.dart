import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/homely_scaffold.dart';

class RecentAppointmentsPage extends StatelessWidget {
  const RecentAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HomelyScaffold(
      selectedIndex: 3,
      body: const Center(
        child: Text(
          'Recent Appointments',
          style: TextStyle(color: AppColors.text),
        ),
      ),
    );
  }
}
