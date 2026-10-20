import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../models/dictionaries.dart';
import '../state/author_list_notifier.dart';
import '../state/book_list_notifier.dart';
import '../widgets/info_row.dart';
import '../widgets/load_state_view.dart';

class BookDetailsScreen extends StatefulWidget {
  final int? id;

  const BookDetailsScreen({super.key, required this.id});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late Future<(Book, List<Author>)?> _future = _load();

  Future<(Book, List<Author>)?> _load() async {
    final id = widget.id;
    if (id == null) return null;
    final books = context.read<BookListNotifier>();
    final authors = context.read<AuthorListNotifier>();
    final book = await books.findById(id);
    if (book == null || book.isDeleted) return null;
    return (book, await authors.findByIds(book.authorIds));
  }

  @override
  void didUpdateWidget(BookDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка книги'),
        leading: IconButton(
          tooltip: 'К списку книг',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/books'),
        ),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorMessage(
              message: 'Не удалось загрузить карточку книги: ${snapshot.error}',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return EmptyMessage(
              title: 'Книга не найдена',
              message: 'Книги с номером ${widget.id ?? '?'} нет в каталоге',
            );
          }
          return _BookDetails(book: data.$1, authors: data.$2);
        },
      ),
    );
  }
}

class _BookDetails extends StatelessWidget {
  final Book book;
  final List<Author> authors;

  const _BookDetails({required this.book, required this.authors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    InfoRow(label: 'ISBN', value: book.isbn),
                    InfoRow(label: 'Год издания', value: '${book.year}'),
                    InfoRow(label: 'Страниц', value: '${book.pages}'),
                    InfoRow(
                      label: 'Издательство',
                      value: publisherNames[book.publisherId] ?? '—',
                    ),
                    InfoRow(
                      label: 'Жанры',
                      value: book.genreIds
                          .map((id) => genreNames[id] ?? '?')
                          .join(', '),
                    ),
                    InfoRow(
                      label: 'Экземпляры',
                      value: 'в наличии ${book.copiesAvailable} '
                          'из ${book.copiesTotal}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Авторы', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            for (final a in authors)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(a.fullName),
                  subtitle: Text(a.country),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/authors/${a.id}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
