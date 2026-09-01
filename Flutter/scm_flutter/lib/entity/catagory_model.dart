class CategoryRequestModel {
  CategoryRequestModel({
    required this.categoryName,
    required this.description,
  });

  final String categoryName;
  final String description;

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'description': description,
    };
  }

  CategoryRequestModel copyWith({
    String? categoryName,
    String? description,
  }) {
    return CategoryRequestModel(
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
    );
  }
}

class CategoryResponseModel {
  CategoryResponseModel({
    required this.id,
    required this.categoryName,
    required this.description,
  });

  final int id;
  final String categoryName;
  final String description;

  factory CategoryResponseModel.fromJson(Map<String, dynamic> json) {
    return CategoryResponseModel(
      id: (json['id'] ?? 0) as int,
      categoryName: (json['categoryName'] ?? '') as String,
      description: (json['description'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'description': description,
    };
  }
}