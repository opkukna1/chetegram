import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class MainScreen extends StatelessWidget {
  // This child widget is the screen that will be displayed
  final Widget child;

  const MainScreen({super.key, required this.child});

  // Function to get the current index from the route location
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/timetable')) {
      return 1;
    }
    if (location.startsWith('/flashcards')) {
      return 2;
    }
    if (location.startsWith('/analytics')) {
      return 3;
    }
    if (location.startsWith('/profile')) {
      return 4;
    }
    return 0;
  }

  // Function to handle navigation when a tab is tapped
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/timetable');
        break;
      case 2:
        context.go('/flashcards');
        break;
      case 3:
        context.go('/analytics');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body is now the child screen passed by the router
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.calendarClock),
            label: 'Time Table',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.layers),
            label: 'Flashcards',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.barChart3),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey.shade600,
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
