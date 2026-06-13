import 'package:flutter/material.dart';

class InputManualScreen extends StatefulWidget {
  const InputManualScreen({super.key});

  @override
  State<InputManualScreen> createState() => _InputManualScreenState();
}

class _InputManualScreenState extends State<InputManualScreen> {
  final _formKey = GlobalKey<FormState>();

  final _merchantController = TextEditingController(text: 'Warung Kopi Jember');
  String _selectedCategory = 'Makanan';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Item List (Mocked initially)
  final List<Map<String, dynamic>> _items = [
    {'name': 'Kopi Hitam', 'qty': 1, 'price': 10000.0},
    {'name': 'Roti Tawar', 'qty': 2, 'price': 7500.0},
  ];

  @override
  void dispose() {
    _merchantController.dispose();
    super.dispose();
  }

  double _calculateSubtotal() {
    return _items.fold(0.0, (sum, item) => sum + (item['qty'] * item['price']));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E5A8),
              onPrimary: Colors.black,
              surface: Color(0xFF141E2E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0B1220),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E5A8),
              onPrimary: Colors.black,
              surface: Color(0xFF141E2E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0B1220),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _showItemModal({int? index}) {
    final bool isEdit = index != null;
    final nameController = TextEditingController(text: isEdit ? _items[index]['name'] : '');
    final priceController = TextEditingController(text: isEdit ? _items[index]['price'].toInt().toString() : '');
    int qty = isEdit ? _items[index]['qty'] : 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double priceVal = double.tryParse(priceController.text) ?? 0.0;
            double subtotalVal = qty * priceVal;

            priceController.addListener(() {
              setModalState(() {
                priceVal = double.tryParse(priceController.text) ?? 0.0;
                subtotalVal = qty * priceVal;
              });
            });

            return AlertDialog(
              backgroundColor: const Color(0xFF141E2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Barang' : 'Tambah Barang',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nama Barang', style: TextStyle(color: Color(0xFF8A99AD), fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildModalInputDecoration(hint: 'Masukkan nama barang'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Jumlah (Quantity)', style: TextStyle(color: Color(0xFF8A99AD), fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (qty > 1) {
                              setModalState(() {
                                qty--;
                                subtotalVal = qty * priceVal;
                              });
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF00E5A8)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B1220),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$qty',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setModalState(() {
                              qty++;
                              subtotalVal = qty * priceVal;
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00E5A8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Harga Satuan', style: TextStyle(color: Color(0xFF8A99AD), fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildModalInputDecoration(hint: 'Rp 0').copyWith(
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFF1F2E46)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(color: Color(0xFF8A99AD), fontSize: 14)),
                        Text(
                          'Rp ${subtotalVal.toInt()}',
                          style: const TextStyle(color: Color(0xFF00E5A8), fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                      final double price = double.tryParse(priceController.text) ?? 0.0;
                      setState(() {
                        if (isEdit) {
                          _items[index] = {'name': nameController.text, 'qty': qty, 'price': price};
                        } else {
                          _items.add({'name': nameController.text, 'qty': qty, 'price': price});
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5A8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Simpan Item', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil disimpan!'),
          backgroundColor: Color(0xFF0C2B29),
        ),
      );
      Navigator.pop(context);
    } else if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan minimal 1 barang!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double subtotal = _calculateSubtotal();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Input Manual Transaksi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Merchant
                _buildLabel('Nama Toko / Merchant'),
                TextFormField(
                  controller: _merchantController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(hint: 'Masukkan nama toko'),
                  validator: (value) => value == null || value.isEmpty ? 'Nama toko tidak boleh kosong' : null,
                ),
                const SizedBox(height: 18),

                // Category & Date Picker Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Kategori'),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            dropdownColor: const Color(0xFF141E2E),
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration(hint: ''),
                            items: const [
                              DropdownMenuItem(value: 'Makanan', child: Text('Makanan')),
                              DropdownMenuItem(value: 'Transportasi', child: Text('Transportasi')),
                              DropdownMenuItem(value: 'Belanja', child: Text('Belanja')),
                              DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Tanggal'),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141E2E),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF1F2E46)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${_selectedDate.toLocal()}".split(' ')[0],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Time Picker
                _buildLabel('Waktu Transaksi'),
                InkWell(
                  onTap: () => _selectTime(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141E2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1F2E46)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTime.format(context),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Icon(Icons.access_time, color: Colors.grey, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Item Details Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DAFTAR BARANG / ITEM',
                      style: TextStyle(
                        color: Color(0xFF8A99AD),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showItemModal(),
                      icon: const Icon(Icons.add, color: Color(0xFF00E5A8), size: 18),
                      label: const Text(
                        'Tambah Barang',
                        style: TextStyle(color: Color(0xFF00E5A8), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Item Details Card list
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final double itemSubtotal = item['qty'] * item['price'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141E2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1F2E46)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${item['qty']} x Rp ${item['price'].toInt()}",
                                  style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Rp ${itemSubtotal.toInt()}",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                                onPressed: () => _showItemModal(index: index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _items.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Summary details
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141E2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1F2E46)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal Seluruh Item', style: TextStyle(color: Color(0xFF8A99AD), fontSize: 14)),
                          Text('Rp ${subtotal.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Pajak / Biaya Layanan', style: TextStyle(color: Color(0xFF8A99AD), fontSize: 14)),
                          Text('Rp 0', style: TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFF1F2E46)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            'Rp ${subtotal.toInt()}',
                            style: const TextStyle(color: Color(0xFF00E5A8), fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Actions buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1F2E46)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5A8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Simpan Transaksi',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF141E2E),
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
