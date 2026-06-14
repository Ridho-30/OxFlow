// lib/models/transaction/category_model.dart

class CategoryModel {
  final int id;
  final String nameCategory;

  CategoryModel({
    required this.id,
    required this.nameCategory,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // GET /api/categories returns: { id: int, name_category: string }
    // Some endpoints may use: { kategori_id: int, kategori_nama: string }
    // category_id is also a possible alias
    final rawId =
        json['id'] ?? json['kategori_id'] ?? json['category_id'];

    final int parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;

    // Try all known field names for the category name
    String name = '';
    for (final key in ['name_category', 'nameCategory', 'kategori_nama', 'name', 'label']) {
      final val = json[key]?.toString().trim() ?? '';
      if (val.isNotEmpty) {
        name = val;
        break;
      }
    }
    if (name.isEmpty) name = 'Lainnya';

    return CategoryModel(id: parsedId, nameCategory: name);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_category': nameCategory,
      };

  @override
  String toString() => 'CategoryModel(id: $id, name: $nameCategory)';
}
