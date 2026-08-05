class Repair {
  final int id;
  final String email;
  final String brokenProperty;
  final String description;
  final String? blockNumber;
  final String? houseNumber;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Repair({
    required this.id,
    required this.email,
    required this.brokenProperty,
    required this.description,
    this.blockNumber,
    this.houseNumber,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Repair.fromJson(Map<String, dynamic> json) {
    return Repair(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      brokenProperty: json['broken_property'] as String? ?? '',
      description: json['description_broken_property'] as String? ?? '',
      blockNumber: json['block_number'] as String?,
      houseNumber: json['house_number'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  String get location {
    if ((blockNumber ?? '').isEmpty && (houseNumber ?? '').isEmpty) {
      return 'Location not specified';
    }
    return 'Block ${blockNumber ?? '-'} - House ${houseNumber ?? '-'}';
  }

  Repair copyWith({String? status}) {
    return Repair(
      id: id,
      email: email,
      brokenProperty: brokenProperty,
      description: description,
      blockNumber: blockNumber,
      houseNumber: houseNumber,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
