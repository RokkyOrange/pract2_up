import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'repositories/author_repository.dart';
import 'repositories/book_repository.dart';
import 'repositories/fake_network.dart';
import 'repositories/in_memory_author_repository.dart';
import 'repositories/in_memory_book_repository.dart';
import 'router.dart';
import 'state/author_list_notifier.dart';
import 'state/book_list_notifier.dart';
import 'state/network_notifier.dart';

void main() {
  usePathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        Provider<FakeNetwork>(create: (_) => FakeNetwork()),
        Provider<BookRepository>(
          create: (context) =>
              InMemoryBookRepository(context.read<FakeNetwork>()),
        ),
        Provider<AuthorRepository>(
          create: (context) =>
              InMemoryAuthorRepository(context.read<FakeNetwork>()),
        ),
        ChangeNotifierProvider(
          create: (context) => NetworkNotifier(context.read<FakeNetwork>()),
        ),
        ChangeNotifierProvider(
          create: (context) => BookListNotifier(context.read<BookRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              AuthorListNotifier(context.read<AuthorRepository>()),
        ),
      ],
      child: const LibraryApp(),
    ),
  );
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Библиотека',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
