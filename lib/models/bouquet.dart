class Bouquet {
  final int id;
  final String name;
  final String sku;
  final int price;
  final int flowersCount;
  final int supplierId;
  final List<int> floristIds;
  final List<int> categoryIds;
  final int stockTotal;
  final int stockAvailable;
  final DateTime? deletedAt;

  const Bouquet({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.flowersCount,
    required this.supplierId,
    required this.floristIds,
    required this.categoryIds,
    required this.stockTotal,
    required this.stockAvailable,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Bouquet copyWith({
    int? id,
    String? name,
    String? sku,
    int? price,
    int? flowersCount,
    int? supplierId,
    List<int>? floristIds,
    List<int>? categoryIds,
    int? stockTotal,
    int? stockAvailable,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Bouquet(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      flowersCount: flowersCount ?? this.flowersCount,
      supplierId: supplierId ?? this.supplierId,
      floristIds: floristIds ?? this.floristIds,
      categoryIds: categoryIds ?? this.categoryIds,
      stockTotal: stockTotal ?? this.stockTotal,
      stockAvailable: stockAvailable ?? this.stockAvailable,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
