import 'package:flutter/material.dart';

import '../features/campus/presentation/campus_screen.dart';
import '../features/personal/presentation/personal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tarteeb')),
    body: SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Text('Demo workspace · Sample data only'),
          ),
          Expanded(
            child: _selectedIndex == 0
                ? const CampusScreen()
                : const PersonalScreen(),
          ),
        ],
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          label: 'Campus',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Personal',
        ),
      ],
    ),
  );
}
