import 'package:go_router/go_router.dart';

import 'screens/author_details_screen.dart';
import 'screens/author_list_screen.dart';
import 'screens/book_details_screen.dart';
import 'screens/book_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/not_found_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/books',
      builder: (context, state) => const BookListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => BookDetailsScreen(
            id: int.tryParse(state.pathParameters['id']!),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/authors',
      builder: (context, state) => const AuthorListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => AuthorDetailsScreen(
            id: int.tryParse(state.pathParameters['id']!),
          ),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      NotFoundScreen(location: state.uri.toString()),
);
