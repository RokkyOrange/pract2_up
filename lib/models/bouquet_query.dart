class BouquetQuery {
  final String search;
  final int? categoryId;
  final int? supplierId;
  final int? priceFrom;
  final int? priceTo;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const BouquetQuery({
    this.search = '',
    this.categoryId,
    this.supplierId,
    this.priceFrom,
    this.priceTo,
    this.sortField = 'name',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  BouquetQuery copyWith({
    String? search,
    Object? categoryId = _unset,
    Object? supplierId = _unset,
    Object? priceFrom = _unset,
    Object? priceTo = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return BouquetQuery(
      search: search ?? this.search,
      categoryId: categoryId == _unset ? this.categoryId : categoryId as int?,
      supplierId: supplierId == _unset ? this.supplierId : supplierId as int?,
      priceFrom: priceFrom == _unset ? this.priceFrom : priceFrom as int?,
      priceTo: priceTo == _unset ? this.priceTo : priceTo as int?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      // Любое изменение условий отбора возвращает на первую страницу
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  static const _unset = Object();
}
