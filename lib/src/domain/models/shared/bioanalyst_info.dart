class BioanalystInfo {
  final String name;
  final String title;
  final String code;
  final String? sealUrl;

  BioanalystInfo({
    required this.name,
    required this.title,
    required this.code,
    this.sealUrl,
  });

  factory BioanalystInfo.fromJson(Map<String, dynamic> json) {
    return BioanalystInfo(
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      code: json['code'] as String? ?? '',
      sealUrl: json['sealUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'code': code,
      if (sealUrl != null) 'sealUrl': sealUrl,
    };
  }

  BioanalystInfo copyWith({
    String? name,
    String? title,
    String? code,
    String? sealUrl,
  }) {
    return BioanalystInfo(
      name: name ?? this.name,
      title: title ?? this.title,
      code: code ?? this.code,
      sealUrl: sealUrl ?? this.sealUrl,
    );
  }
}

/// Alias para mantener retrocompatibilidad total con referencias a BranchBioanalyst
typedef BranchBioanalyst = BioanalystInfo;
