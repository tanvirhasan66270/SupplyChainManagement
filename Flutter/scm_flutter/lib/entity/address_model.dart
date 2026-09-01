class AddressItem {
  AddressItem({
    required this.id,
    required this.name,
    this.nameBn,
  });

  final int id;
  final String name;
  final String? nameBn;

  factory AddressItem.fromJson(Map<String, dynamic> json) => AddressItem(
    id: (json['id'] as num).toInt(),
    name: (json['name'] ?? '') as String,
    nameBn: json['nameBn'] as String?,
  );
}