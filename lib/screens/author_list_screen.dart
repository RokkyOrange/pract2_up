import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../state/author_list_notifier.dart';
import '../state/load_status.dart';
import '../widgets/load_state_view.dart';
import '../widgets/offline_toggle.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/search_field.dart';

class AuthorListScreen extends StatefulWidget {
  const AuthorListScreen({super.key});

  @override
  State<AuthorListScreen> createState() => _AuthorListScreenState();
}

class _AuthorListScreenState extends State<AuthorListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AuthorListNotifier>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AuthorListNotifier>();
    final search = notifier.query.search;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Авторы'),
        leading: IconButton(
          tooltip: 'На главную',
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
        ),
        actions: [
          OfflineToggle(onChanged: notifier.load),
          IconButton(
            tooltip: 'Обновить',
            icon: const Icon(Icons.refresh),
            onPressed: notifier.load,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              SearchField(
                initialText: search,
                hint: 'Фамилия или страна, затем Enter',
                onSearch: notifier.search,
              ),
              Expanded(
                child: LoadStateView(
                  status: notifier.status,
                  isEmpty: notifier.result.items.isEmpty,
                  error: notifier.error,
                  onRetry: notifier.load,
                  emptyTitle: 'Ничего не найдено',
                  emptyMessage: search.isEmpty
                      ? 'В каталоге пока нет авторов'
                      : 'По запросу «$search» авторов не найдено',
                  onResetSearch:
                      search.isEmpty ? null : () => notifier.search(''),
                  builder: (context) => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notifier.result.items.length,
                    itemBuilder: (context, i) =>
                        _AuthorTile(author: notifier.result.items[i]),
                  ),
                ),
              ),
              if (notifier.status == LoadStatus.success &&
                  notifier.result.items.isNotEmpty)
                PaginationBar(
                  result: notifier.result,
                  onPage: notifier.goToPage,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthorTile extends StatelessWidget {
  final Author author;

  const _AuthorTile({required this.author});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(author.lastName[0])),
        title: Text(author.fullName),
        subtitle: Text('${author.country} · ${author.birthYear} г. р.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/authors/${author.id}'),
      ),
    );
  }
}
