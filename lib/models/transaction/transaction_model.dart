// lib/models/transaction/transaction_model.dart

import 'category_model.dart';

class TransactionDetailModel {
  final int? id;
  final String nameItems;
  final int quantity;
  final double price;
  final double subtotal;

  TransactionDetailModel({
    this.id,
    required this.nameItems,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      id: json['detail_transaction_id'] as int? ?? json['id'] as int?,
      nameItems: json['name_items']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'detail_transaction_id': id,
        'name_items': nameItems,
        'quantity': quantity,
        'price': price,
        'subtotal': subtotal,
      };
}

class TransactionModel {
  final String id;
  final int categoryId;
  final CategoryModel? category;
  final double total;
  final DateTime date;
  final String? fotoStruk;
  final List<TransactionDetailModel> details;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? storeName;

  TransactionModel({
    required this.id,
    required this.categoryId,
    this.category,
    required this.total,
    required this.date,
    this.fotoStruk,
    required this.details,
    this.createdAt,
    this.updatedAt,
    this.storeName,
  });

  String get title {
    if (storeName != null && storeName!.trim().isNotEmpty) {
      return storeName!;
    }
    if (details.isNotEmpty) {
      return details.first.nameItems;
    }
    return category?.nameCategory ?? 'Lainnya';
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel.fromJsonWithCategories(json, {});
  }

  /// Use this factory when you have a pre-fetched category lookup map.
  /// [categoryLookup] is a Map of categoryId to categoryName from GET /api/categories.
  factory TransactionModel.fromJsonWithCategories(
    Map<String, dynamic> json,
    Map<int, String> categoryLookup,
  ) {
    // Parse category — API only returns category_id in the list endpoint,
    // so we look up the name from the preloaded categoryLookup map.
    final int catId =
        json['category_id'] as int? ?? json['kategori_id'] as int? ?? 0;

    CategoryModel? cat;
    if (json['category'] != null) {
      // Nested object present (e.g., from a detail endpoint)
      cat = CategoryModel.fromJson(json['category'] as Map<String, dynamic>);
    } else if (categoryLookup.containsKey(catId)) {
      cat = CategoryModel(id: catId, nameCategory: categoryLookup[catId]!);
    } else if (json['kategori_nama'] != null) {
      cat = CategoryModel.fromJson(json);
    }

    // Parse details list
    final detailsList = <TransactionDetailModel>[];
    if (json['details'] != null) {
      final list = json['details'] as List;
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          detailsList.add(TransactionDetailModel.fromJson(item));
        }
      }
    }

    return TransactionModel(
      id: (json['id'] ?? json['transaction_id'] ?? 0).toString(),
      categoryId: catId,
      category: cat,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      fotoStruk: json['foto_struk']?.toString(),
      details: detailsList,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      storeName: json['store_name']?.toString() ?? json['merchant']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'total': total,
        'date': date.toIso8601String().split('T')[0],
        'foto_struk': fotoStruk,
        'details': details.map((e) => e.toJson()).toList(),
        'store_name': storeName,
      };
}
