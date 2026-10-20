import 'package:flutter/material.dart';

import '../models/page_result.dart';

class PaginationBar extends StatelessWidget {
  final PageResult<Object?> result;
  final ValueChanged<int> onPage;

  const PaginationBar({super.key, required this.result, required this.onPage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: 'Предыдущая страница',
            icon: const Icon(Icons.chevron_left),
            onPressed:
                result.hasPrevious ? () => onPage(result.page - 1) : null,
          ),
          Text(
            'Страница ${result.page} из ${result.totalPages} · '
            'всего записей: ${result.total}',
          ),
          IconButton(
            tooltip: 'Следующая страница',
            icon: const Icon(Icons.chevron_right),
            onPressed: result.hasNext ? () => onPage(result.page + 1) : null,
          ),
        ],
      ),
    );
  }
}
