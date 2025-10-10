import 'package:chetegram/screens/add_task_screen.dart';
import 'package:chetegram/screens/analytics_screen.dart';
import 'package:chetegram/screens/flashcards_screen.dart';
import 'package:chetegram/screens/home_screen.dart';
import 'package:chetegram/screens/main_screen.dart';
import 'package:chetegram/screens/profile_screen.dart';
import 'package:chetegram/screens/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  initialLocation: '/home',
  navigatorKey: _rootNavigatorKey,
  routes: [
    // This route is for the Add Task screen. It's outside the ShellRoute
    // so it covers the whole screen, including the bottom navigation bar.
    GoRoute(
      path: '/add-task',
      builder: (context, state) => const AddTaskScreen(),
    ),
    
    // This ShellRoute builds the UI with the BottomNavigationBar
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScreen(child: child); // Pass the child screen to MainScreen
      },
      routes: [
        // Routes for each tab
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/timetable',
          builder: (context, state) => const TimeTableScreen(),
        ),
        GoRoute(
          path: '/flashcards',
          builder: (context, state) => const FlashcardsScreen(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
