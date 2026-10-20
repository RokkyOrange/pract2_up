import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'repositories/bouquet_repository.dart';
import 'repositories/fake_network.dart';
import 'repositories/florist_repository.dart';
import 'repositories/in_memory_bouquet_repository.dart';
import 'repositories/in_memory_florist_repository.dart';
import 'router.dart';
import 'state/bouquet_list_notifier.dart';
import 'state/florist_list_notifier.dart';
import 'state/network_notifier.dart';

void main() {
  usePathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        Provider<FakeNetwork>(create: (_) => FakeNetwork()),
        Provider<BouquetRepository>(
          create: (context) =>
              InMemoryBouquetRepository(context.read<FakeNetwork>()),
        ),
        Provider<FloristRepository>(
          create: (context) =>
              InMemoryFloristRepository(context.read<FakeNetwork>()),
        ),
        ChangeNotifierProvider(
          create: (context) => NetworkNotifier(context.read<FakeNetwork>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              BouquetListNotifier(context.read<BouquetRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              FloristListNotifier(context.read<FloristRepository>()),
        ),
      ],
      child: const FlowerShopApp(),
    ),
  );
}

class FlowerShopApp extends StatelessWidget {
  const FlowerShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Цветочный магазин',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
