import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../models/dictionaries.dart';
import '../state/book_list_notifier.dart';
import '../state/load_status.dart';
import '../widgets/load_state_view.dart';
import '../widgets/offline_toggle.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/search_field.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  @override
  void initState() {
    super.initState();
    // Данные перезапрашиваются при каждом открытии экрана
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<BookListNotifier>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BookListNotifier>();
    final search = notifier.query.search;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Книги'),
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
                hint: 'Название или ISBN, затем Enter',
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
                      ? 'В каталоге пока нет книг'
                      : 'По запросу «$search» книг не найдено',
                  onResetSearch:
                      search.isEmpty ? null : () => notifier.search(''),
                  builder: (context) => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notifier.result.items.length,
                    itemBuilder: (context, i) =>
                        _BookTile(book: notifier.result.items[i]),
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

class _BookTile extends StatelessWidget {
  final Book book;

  const _BookTile({required this.book});

  @override
  Widget build(BuildContext context) {
    final genres = book.genreIds.map((id) => genreNames[id] ?? '?').join(', ');
    final publisher = publisherNames[book.publisherId] ?? '?';
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.menu_book)),
        title: Text(book.title),
        subtitle: Text(
          '${book.year} г. · $genres · $publisher\nISBN ${book.isbn}',
        ),
        isThreeLine: true,
        trailing: Text(
          'В наличии\n${book.copiesAvailable} из ${book.copiesTotal}',
          textAlign: TextAlign.end,
        ),
        onTap: () => context.go('/books/${book.id}'),
      ),
    );
  }
}
