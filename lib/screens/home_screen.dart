import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/network_notifier.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final network = context.watch<NetworkNotifier>();
    return Scaffold(
      appBar: AppBar(title: const Text('Цветочный магазин — каталог')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              Text(
                'Выберите раздел каталога',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _SectionCard(
                icon: Icons.local_florist,
                title: 'Букеты',
                subtitle: 'Список букетов с поиском по названию и артикулу',
                onTap: () => context.go('/bouquets'),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.person,
                title: 'Флористы',
                subtitle: 'Список флористов с поиском по фамилии и городу',
                onTap: () => context.go('/florists'),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Имитировать ошибку сервера'),
                subtitle: const Text(
                  'Все запросы к данным будут завершаться ошибкой',
                ),
                value: network.offline,
                onChanged: network.setOffline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, size: 36),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
