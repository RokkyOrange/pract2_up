import 'package:go_router/go_router.dart';

import 'screens/bouquet_details_screen.dart';
import 'screens/bouquet_list_screen.dart';
import 'screens/florist_details_screen.dart';
import 'screens/florist_list_screen.dart';
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
      path: '/bouquets',
      builder: (context, state) => const BouquetListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => BouquetDetailsScreen(
            id: int.tryParse(state.pathParameters['id']!),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/florists',
      builder: (context, state) => const FloristListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => FloristDetailsScreen(
            id: int.tryParse(state.pathParameters['id']!),
          ),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      NotFoundScreen(location: state.uri.toString()),
);
