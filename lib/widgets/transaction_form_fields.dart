// lib/widgets/transaction_form_fields.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction/category_model.dart';
import '../services/api/api_endpoints.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/laporan_provider.dart';
import '../models/transaction/transaction_model.dart';
import '../services/ocr/receipt_parser.dart';

class TransactionFormFields extends ConsumerStatefulWidget {
  final ParsedReceipt? initialData;
  final TransactionModel? existingTransaction;
  final String? imagePath;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const TransactionFormFields({
    super.key,
    this.initialData,
    this.existingTransaction,
    this.imagePath,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  ConsumerState<TransactionFormFields> createState() =>
      _TransactionFormFieldsState();
}

class _TransactionFormFieldsState extends ConsumerState<TransactionFormFields> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetchingCategories = true;

  late TextEditingController _storeNameController;
  late TextEditingController _pajakController;
  late List<Map<String, dynamic>> _items;

  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();

    final tx = widget.existingTransaction;
    final initial = widget.initialData;

    // Initialize form values from existingTransaction (Edit), initialData (OCR), or empty (Manual)
    _storeNameController = TextEditingController(
      text: tx?.title ?? initial?.storeName ?? '',
    );

    // Hitung pajak dari items tax? 
    // Wait, existingTransaction details might include tax. 
    // In LaporanTransactionDetailSheet, tax is not separated from details, but saved as an item.
    // Let's filter out "Pajak / Fee Tambahan" if it exists in details.
    
    List<Map<String, dynamic>> itemsList = [];
    double initialTax = 0.0;

    if (tx != null) {
      for (var d in tx.details) {
        if (d.nameItems.toLowerCase().contains('pajak') || d.nameItems.toLowerCase().contains('fee tambahan')) {
          initialTax += d.subtotal;
        } else {
          itemsList.add({
            'name': d.nameItems,
            'qty': d.quantity,
            'price': d.price,
          });
        }
      }
    } else if (initial != null) {
      initialTax = initial.tax > 0 ? initial.tax : 0.0;
      itemsList = initial.items.map((item) => <String, dynamic>{
        'name': item.name,
        'qty': item.quantity,
        'price': item.unitPrice,
      }).toList();
    }

    _pajakController = TextEditingController(
      text: initialTax > 0 ? initialTax.toInt().toString() : '0',
    );

    _items = itemsList;

    _fetchCategories();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _pajakController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await ref
          .read(apiClientProvider)
          .get(ApiEndpoints.categories);
      List<dynamic> list = [];
      if (response is List) {
        list = response;
      } else if (response is Map<String, dynamic>) {
        list = response['data'] ?? response['categories'] ?? [];
      }

      final List<CategoryModel> parsedCategories = [];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          parsedCategories.add(CategoryModel.fromJson(item));
        }
      }

      if (mounted) {
        setState(() {
          _categories = parsedCategories;
          _isFetchingCategories = false;

          if (_categories.isNotEmpty) {
            // Smart auto-select food or grocery categories for OCR validation
            if (widget.existingTransaction != null) {
              _selectedCategory = _categories.firstWhere(
                (c) => c.id == widget.existingTransaction!.category?.id,
                orElse: () => _categories.first,
              );
            } else if (widget.initialData != null) {
              _selectedCategory = _categories.firstWhere(
                (c) =>
                    c.nameCategory.toLowerCase().contains('makan') ||
                    c.nameCategory.toLowerCase().contains('belanja') ||
                    c.nameCategory.toLowerCase().contains('kuliner'),
                orElse: () => _categories.first,
              );
            } else {
              _selectedCategory = _categories.first;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('[TransactionFormFields] Error fetching categories: $e');
      if (mounted) {
        setState(() {
          _isFetchingCategories = false;
        });
      }
    }
  }

  double get _subtotal =>
      _items.fold(0.0, (sum, item) => sum + (item['qty'] * item['price']));
  double get _tax => double.tryParse(_pajakController.text) ?? 0.0;
  double get _total => _subtotal + _tax;

  Future<void> _showItemDialog({int? index}) async {
    final bool isEdit = index != null;

    // Controllers live outside the builder so they don't reset on rebuild
    final nameCtrl = TextEditingController(
      text: isEdit ? (_items[index]['name'] as String) : '',
    );
    final priceCtrl = TextEditingController(
      text: isEdit ? (_items[index]['price'] as double).toInt().toString() : '',
    );

    // Mutable dialog state — declared outside builder so they survive rebuilds
    int dialogQty = isEdit ? (_items[index]['qty'] as int) : 1;
    double dialogPrice = isEdit ? (_items[index]['price'] as double) : 0.0;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogCtx) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (BuildContext statefulCtx, StateSetter setDialogState) {
            final double dialogSubtotal = dialogQty * dialogPrice;

            return AlertDialog(
              backgroundColor: const Color(0xFF141E2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Barang' : 'Tambah Barang',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(dialogCtx),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Nama Barang ─────────────────────────────────
                    const Text(
                      'Nama Barang',
                      style: TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.words,
                      decoration: _buildModalInputDecoration(
                        hint: 'Masukkan nama barang',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Quantity stepper ───────────────────────────
                    const Text(
                      'Jumlah (Quantity)',
                      style: TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (dialogQty > 1) {
                              setDialogState(() => dialogQty--);
                            }
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Color(0xFF00E5A8),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B1220),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$dialogQty',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setDialogState(() => dialogQty++),
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF00E5A8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Harga satuan ────────────────────────────
                    const Text(
                      'Harga Satuan',
                      style: TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildModalInputDecoration(hint: '0')
                          .copyWith(
                            prefixText: 'Rp ',
                            prefixStyle: const TextStyle(color: Colors.white),
                          ),
                      // onChanged — NOT addListener — so no duplicate listeners
                      onChanged: (val) {
                        setDialogState(() {
                          dialogPrice = double.tryParse(val) ?? 0.0;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFF1F2E46)),
                    const SizedBox(height: 12),

                    // ── Live subtotal preview ──────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(
                            color: Color(0xFF8A99AD),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Rp ${dialogSubtotal.toInt()}',
                          style: const TextStyle(
                            color: Color(0xFF00E5A8),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () async {
                    setDialogState(() => isSaving = true);
                    // Lepas focus dari TextField agar keyboard turun dan FocusNode detach
                    FocusScope.of(statefulCtx).unfocus();
                    
                    // Tunggu sesaat agar proses unfocus selesai sebelum dialog di-dispose
                    await Future.delayed(Duration.zero);
                    if (!statefulCtx.mounted) return;
                    
                    Navigator.pop(dialogCtx);
                  },
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: isSaving ? Colors.grey.withValues(alpha: 0.5) : Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    setDialogState(() => isSaving = true);
                    // Lepas focus dari TextField agar keyboard turun dan FocusNode detach
                    FocusScope.of(statefulCtx).unfocus();
                    
                    // Tunggu sesaat agar proses unfocus dan detach keyboard selesai
                    await Future.delayed(Duration.zero);
                    if (!statefulCtx.mounted) return;

                    final trimmedName = nameCtrl.text.trim();
                    if (trimmedName.isEmpty) {
                      ScaffoldMessenger.of(statefulCtx).showSnackBar(
                        const SnackBar(
                          content: Text('Nama barang tidak boleh kosong!', style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.redAccent,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      setDialogState(() => isSaving = false);
                      return;
                    }

                    final newItem = <String, dynamic>{
                      'name': trimmedName,
                      'qty': dialogQty,
                      'price': dialogPrice,
                    };

                    // Bug 3 FIX: Kembalikan data ke pemanggil lewat Navigator.pop
                    // alih-alih memanggil setState() Parent secara langsung dari dalam dialog
                    Navigator.pop(dialogCtx, newItem);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSaving ? const Color(0xFF00E5A8).withValues(alpha: 0.5) : const Color(0xFF00E5A8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Simpan Item',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // Clean up controllers
    nameCtrl.dispose();
    priceCtrl.dispose();

    // Jika user menekan "Simpan Item", result tidak null
    // Lakukan update state pada Parent (aman karena Dialog sudah pop & animasi dijadwalkan)
    if (result != null && mounted) {
      setState(() {
        if (isEdit) {
          _items[index] = result;
        } else {
          _items.add(result);
        }
      });
    }
  }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141E2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Hapus Item',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Hapus item '${_items[index]['name']}'?",
            style: const TextStyle(color: Color(0xFF8A99AD)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _items.removeAt(index);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan minimal 1 barang!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori terlebih dahulu!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      // Keep existing transaction date if editing
      final txDate = widget.existingTransaction?.date.toIso8601String().split('T')[0] ?? 
                     now.toIso8601String().split('T')[0];

      final List<Map<String, dynamic>> detailsPayload = _items
          .map(
            (item) => <String, dynamic>{
              'name_items': item['name'] as String,
              'quantity': item['qty'] as int,
              'price': (item['price'] as num).toDouble(),
              'subtotal': (item['qty'] * item['price'] as num).toDouble(),
            },
          )
          .toList();

      if (_tax > 0) {
        detailsPayload.add(<String, dynamic>{
          'name_items': 'Pajak / Fee Tambahan',
          'quantity': 1,
          'price': _tax,
          'subtotal': _tax,
        });
      }

      final Map<String, dynamic> transactionPayload = {
        'category_id': _selectedCategory!.id,
        'total': _total,
        'date': txDate,
        'nama_toko': _storeNameController.text.trim(),
        'details': detailsPayload,
      };

      if (widget.existingTransaction != null) {
        await ref
            .read(laporanProvider.notifier)
            .updateTransaction(widget.existingTransaction!.id, transactionPayload);
      } else {
        await ref
            .read(apiClientProvider)
            .post(ApiEndpoints.transactions, data: transactionPayload);
      }

      if (!mounted) return;

      // Invalidate providers to refresh dashboard & report logs
      ref.invalidate(dashboardProvider);
      ref.invalidate(laporanProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingTransaction != null 
                ? 'Transaksi berhasil diperbarui!' 
                : 'Transaksi berhasil disimpan!',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0C2B29),
        ),
      );

      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan transaksi: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5A8)),
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Name / Merchant
          _buildLabel('Nama Toko'),
          TextFormField(
            controller: _storeNameController,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration(
              hint: 'Masukkan nama toko',
              icon: Icons.store,
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Nama toko tidak boleh kosong'
                : null,
          ),
          const SizedBox(height: 18),

          // Category Dropdown Selection
          _buildLabel('Kategori'),
          _isFetchingCategories
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141E2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1F2E46)),
                  ),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00E5A8),
                    ),
                  ),
                )
              : DropdownButtonFormField<CategoryModel>(
                  initialValue: _selectedCategory,
                  dropdownColor: const Color(0xFF141E2E),
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    hint: 'Pilih Kategori',
                    icon: Icons.category,
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem<CategoryModel>(
                      value: cat,
                      child: Text(cat.nameCategory),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
          const SizedBox(height: 24),

          // Items List Header — Flexible prevents overflow (Bug 3)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'DAFTAR BARANG',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF8A99AD),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showItemDialog(),
                icon: const Icon(Icons.add, color: Color(0xFF00E5A8), size: 18),
                label: const Text(
                  'Tambah',
                  style: TextStyle(
                    color: Color(0xFF00E5A8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Render Item dynamic list
          if (_items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Belum ada item belanja ditambahkan',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final double itemSub = item['qty'] * item['price'];
                final bool isIncomplete =
                    item['name'].contains('[') || item['price'] <= 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141E2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isIncomplete
                          ? Colors.orangeAccent.withValues(alpha: 0.5)
                          : const Color(0xFF1F2E46),
                      width: isIncomplete ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                if (isIncomplete)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B2E1A),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Koreksi',
                                      style: TextStyle(
                                        color: Colors.orangeAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${item['qty']} x Rp ${item['price'].toInt()}",
                              style: const TextStyle(
                                color: Color(0xFF8A99AD),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "Rp ${itemSub.toInt()}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () => _showItemDialog(index: index),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () => _deleteItem(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 24),

          // Pajak / Fee input field
          _buildLabel('Pajak / Fee Tambahan'),
          TextFormField(
            controller: _pajakController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration:
                _buildInputDecoration(
                  hint: '0',
                  icon: Icons.receipt_long,
                ).copyWith(
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(color: Colors.white),
                ),
            onChanged: (_) {
              setState(() {}); // trigger rebuild to update total
            },
          ),
          const SizedBox(height: 28),

          // Calculation summary details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF141E2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1F2E46)),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  'Subtotal Seluruh Item',
                  'Rp ${_subtotal.toInt()}',
                ),
                const SizedBox(height: 10),
                _buildSummaryRow('Pajak / Fee', 'Rp ${_tax.toInt()}'),
                const Divider(color: Color(0xFF1F2E46), height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'GRAND TOTAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Rp ${_total.toInt()}',
                      style: const TextStyle(
                        color: Color(0xFF00E5A8),
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1F2E46)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5A8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Transaksi',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
        ),
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF141E2E),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1F2E46)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1F2E46)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00E5A8)),
      ),
    );
  }

  InputDecoration _buildModalInputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF0B1220),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1F2E46)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1F2E46)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00E5A8)),
      ),
    );
  }
}
