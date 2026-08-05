class MarketplaceItem {
  final int id;
  final String name;
  final String description;
  final String quantity;
  final String offer;
  final String category;
  final String? ownerEmail;
  final bool published;

  const MarketplaceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.offer,
    required this.category,
    this.ownerEmail,
    required this.published,
  });

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) {
    return MarketplaceItem(
      id: json['id'] as int,
      name: json['goods_name'] as String? ?? '',
      description: json['goods_description'] as String? ?? '',
      quantity: json['goods_quantity'] as String? ?? '',
      offer: json['any_offer'] as String? ?? '',
      category: (json['category'] as String?)?.isNotEmpty == true
          ? json['category'] as String
          : 'General',
      ownerEmail: json['owner_email'] as String?,
      published: json['status'] == 1,
    );
  }
}
