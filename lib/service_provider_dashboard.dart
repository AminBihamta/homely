import 'package:flutter/material.dart';

class ServiceProviderDashboard extends StatelessWidget {
  const ServiceProviderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Provider Dashboard')),
      body: const Center(
        child: Text(
          'Service Provider Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
