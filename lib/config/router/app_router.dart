import 'package:chetegram/models/flashcard_model.dart';
import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/screens/add_flashcard_screen.dart';
import 'package:chetegram/screens/add_task_screen.dart';
import 'package:chetegram/screens/add_timetable_screen.dart';
import 'package:chetegram/screens/analytics_screen.dart';
import 'package:chetegram/screens/edit_task_screen.dart';
import 'package:chetegram/screens/flashcard_viewer_screen.dart';
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
    GoRoute(
      path: '/add-task',
      builder: (context, state) => const AddTaskScreen(),
    ),
    GoRoute(
      path: '/add-flashcard',
      builder: (context, state) => const AddFlashcardScreen(),
    ),
     GoRoute(
      path: '/add-timetable',
      builder: (context, state) => const AddTimeTableScreen(),
    ),
    GoRoute(
      path: '/flashcard-viewer',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        final List<Flashcard> flashcards = data['flashcards'];
        final int index = data['index'];
        return FlashcardViewerScreen(flashcards: flashcards, initialIndex: index);
      },
    ),
    GoRoute(
      path: '/edit-task',
      builder: (context, state) {
        final task = state.extra as Task;
        return EditTaskScreen(task: task);
      },
    ),
    
    // Main App Shell
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
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
