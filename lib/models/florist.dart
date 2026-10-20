class Florist {
  final int id;
  final String lastName;
  final String firstName;
  final String? middleName;
  final String city;
  final int experienceYears;
  final DateTime? deletedAt;

  const Florist({
    required this.id,
    required this.lastName,
    required this.firstName,
    this.middleName,
    required this.city,
    required this.experienceYears,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  /// Иванова Анна Сергеевна
  String get fullName =>
      [lastName, firstName, if (middleName != null) middleName].join(' ');

  Florist copyWith({
    int? id,
    String? lastName,
    String? firstName,
    String? middleName,
    String? city,
    int? experienceYears,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Florist(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      city: city ?? this.city,
      experienceYears: experienceYears ?? this.experienceYears,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
