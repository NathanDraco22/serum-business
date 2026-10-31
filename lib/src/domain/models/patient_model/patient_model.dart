class BasePatient {
  final String name;
  final int dateOfBirth;
  final String gender;
  final String phone;
  final String? address;
  final String? email;
  final String? cardId;
  final String originBranch;
  final int? explicitAge;

  BasePatient({
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.phone,
    this.address,
    this.email,
    this.cardId,
    required this.originBranch,
    int? age,
  }) : explicitAge = age;

  int get age {
    if (explicitAge != null && explicitAge! >= 0) return explicitAge!;
    if (dateOfBirth <= 0) return 0;
    final birth = DateTime.fromMillisecondsSinceEpoch(dateOfBirth);
    final today = DateTime.now();
    int a = today.year - birth.year;
    if (today.month < birth.month ||
        (today.month == birth.month && today.day < birth.day)) {
      a--;
    }
    return a >= 0 ? a : 0;
  }
}

class CreatePatient extends BasePatient {
  CreatePatient({
    required super.name,
    required super.dateOfBirth,
    required super.gender,
    required super.phone,
    super.address,
    super.email,
    super.cardId,
    required super.originBranch,
    super.age,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'phone': phone,
      'address': address,
      'email': email,
      'cardId': cardId,
      'originBranch': originBranch,
      'age': age,
    };
  }
}

class UpdatePatient {
  final String? name;
  final int? dateOfBirth;
  final String? gender;
  final String? phone;
  final String? address;
  final String? email;
  final String? cardId;
  final String? originBranch;
  final int? age;

  UpdatePatient({
    this.name,
    this.dateOfBirth,
    this.gender,
    this.phone,
    this.address,
    this.email,
    this.cardId,
    this.originBranch,
    this.age,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (email != null) 'email': email,
      if (cardId != null) 'cardId': cardId,
      if (originBranch != null) 'originBranch': originBranch,
      if (age != null) 'age': age,
    };
  }
}

class PatientInDb extends BasePatient {
  final String id;
  final int createdAt;
  final int? updatedAt;
  final bool isDeleted;

  PatientInDb({
    required this.id,
    required super.name,
    required super.dateOfBirth,
    required super.gender,
    required super.phone,
    super.address,
    super.email,
    super.cardId,
    required super.originBranch,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    super.age,
  });

  factory PatientInDb.fromJson(Map<String, dynamic> json) {
    return PatientInDb(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: json['dateOfBirth'] as int,
      gender: json['gender'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      email: json['email'] as String?,
      cardId: json['cardId'] as String?,
      originBranch: json['originBranch'] as String? ?? '',
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      age: json['age'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'phone': phone,
      'address': address,
      'email': email,
      'cardId': cardId,
      'originBranch': originBranch,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
      'age': age,
    };
  }
}
