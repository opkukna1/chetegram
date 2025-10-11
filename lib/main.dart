import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    // .startsWith() का उपयोग करें ताकि /profile/123 जैसी सब-रूट्स भी सही टैब दिखाएं
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/timetable')) return 1;
    if (location.startsWith('/flashcards')) return 2;
    if (location.startsWith('/analytics')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

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
        context.go('/profile'); // यह अब सही रूट है
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Time Table'),
          BottomNavigationBarItem(icon: Icon(Icons.layers), label: 'Flashcards'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
