import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../state/author_list_notifier.dart';
import '../state/book_list_notifier.dart';
import '../widgets/info_row.dart';
import '../widgets/load_state_view.dart';

class AuthorDetailsScreen extends StatefulWidget {
  final int? id;

  const AuthorDetailsScreen({super.key, required this.id});

  @override
  State<AuthorDetailsScreen> createState() => _AuthorDetailsScreenState();
}

class _AuthorDetailsScreenState extends State<AuthorDetailsScreen> {
  late Future<(Author, List<Book>)?> _future = _load();

  Future<(Author, List<Book>)?> _load() async {
    final id = widget.id;
    if (id == null) return null;
    final authors = context.read<AuthorListNotifier>();
    final books = context.read<BookListNotifier>();
    final author = await authors.findById(id);
    if (author == null || author.isDeleted) return null;
    return (author, await books.findByAuthor(id));
  }

  @override
  void didUpdateWidget(AuthorDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка автора'),
        leading: IconButton(
          tooltip: 'К списку авторов',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/authors'),
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
              message:
                  'Не удалось загрузить карточку автора: ${snapshot.error}',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return EmptyMessage(
              title: 'Автор не найден',
              message: 'Автора с номером ${widget.id ?? '?'} нет в каталоге',
            );
          }
          return _AuthorDetails(author: data.$1, books: data.$2);
        },
      ),
    );
  }
}

class _AuthorDetails extends StatelessWidget {
  final Author author;
  final List<Book> books;

  const _AuthorDetails({required this.author, required this.books});

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
                    Text(author.fullName,
                        style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    InfoRow(label: 'Фамилия', value: author.lastName),
                    InfoRow(label: 'Имя', value: author.firstName),
                    InfoRow(label: 'Отчество', value: author.middleName ?? '—'),
                    InfoRow(label: 'Страна', value: author.country),
                    InfoRow(
                        label: 'Год рождения', value: '${author.birthYear}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Книги автора в каталоге (${books.length})',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            if (books.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('В каталоге нет книг этого автора'),
              ),
            for (final b in books)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: Text(b.title),
                  subtitle: Text('${b.year} г. · ${b.pages} стр.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/books/${b.id}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
