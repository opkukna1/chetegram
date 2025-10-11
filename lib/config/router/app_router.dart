import 'package:chetegram/models/flashcard_model.dart';
import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/screens/add_flashcard_screen.dart';
import 'package:chetegram/screens/add_task_screen.dart';
import 'package:chetegram/screens/add_timetable_screen.dart';
import 'package:chetegram/screens/analytics_screen.dart';
import 'package:chetegram/screens/auth/login_screen.dart';
import 'package:chetegram/screens/auth/signup_screen.dart';
import 'package:chetegram/screens/edit_task_screen.dart';
import 'package:chetegram/screens/flashcard_viewer_screen.dart';
import 'package:chetegram/screens/flashcards_screen.dart';
import 'package:chetegram/screens/home_screen.dart';
import 'package:chetegram/screens/main_screen.dart';
import 'package:chetegram/screens/profile/edit_profile_screen.dart';
import 'package:chetegram/screens/profile/user_list_screen.dart';
import 'package:chetegram/screens/profile/user_search_screen.dart';
import 'package:chetegram/screens/profile_screen.dart';
import 'package:chetegram/screens/timetable_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  initialLocation: '/login',
  navigatorKey: _rootNavigatorKey,
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final bool loggingIn = state.uri.path == '/login' || state.uri.path == '/signup';

    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn) return '/home';
    return null;
  },
  routes: [
    // --- टॉप लेवल रूट्स (जो बॉटम बार को छिपा देते हैं) ---
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/add-task', builder: (context, state) => const AddTaskScreen()),
    GoRoute(path: '/add-flashcard', builder: (context, state) => const AddFlashcardScreen()),
    GoRoute(path: '/add-timetable', builder: (context, state) => const AddTimeTableScreen()),
    GoRoute(
      path: '/edit-task',
      builder: (context, state) => EditTaskScreen(task: state.extra as Task),
    ),
    GoRoute(path: '/edit-profile', builder: (context, state) => const EditProfileScreen()),
    GoRoute(path: '/search', builder: (context, state) => const UserSearchScreen()),
    GoRoute(
      path: '/flashcard-viewer',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return FlashcardViewerScreen(flashcards: data['flashcards'], initialIndex: data['index']);
      },
    ),
    GoRoute(
      path: '/user-list',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return UserListScreen(userId: data['userId'], listType: data['listType']);
      },
    ),
    // दूसरों की प्रोफाइल देखने के लिए नया रूट
    GoRoute(
      path: '/view-profile/:userId', 
      builder: (context, state) {
        final userId = state.pathParameters['userId'];
        return ProfileScreen(userId: userId);
      },
    ),
    
    // --- बॉटम बार वाले रूट्स ---
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/timetable', builder: (context, state) => const TimeTableScreen()),
        GoRoute(path: '/flashcards', builder: (context, state) => const FlashcardsScreen()),
        GoRoute(path: '/analytics', builder: (context, state) => const AnalyticsScreen()),
        // प्रोफाइल टैब के लिए नया और सही रूट
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(), // यहाँ कोई userId नहीं है
        ),
      ],
    ),
  ],
);
