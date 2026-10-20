class Author {
  final int id;
  final String lastName;
  final String firstName;
  final String? middleName;
  final String country;
  final int birthYear;
  final DateTime? deletedAt;

  const Author({
    required this.id,
    required this.lastName,
    required this.firstName,
    this.middleName,
    required this.country,
    required this.birthYear,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  /// Толстой Лев Николаевич
  String get fullName =>
      [lastName, firstName, if (middleName != null) middleName].join(' ');

  /// Толстой Л. Н.
  String get shortName {
    final initials = [
      '${firstName[0]}.',
      if (middleName != null) '${middleName![0]}.',
    ].join(' ');
    return '$lastName $initials';
  }

  Author copyWith({
    int? id,
    String? lastName,
    String? firstName,
    String? middleName,
    String? country,
    int? birthYear,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Author(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      country: country ?? this.country,
      birthYear: birthYear ?? this.birthYear,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
