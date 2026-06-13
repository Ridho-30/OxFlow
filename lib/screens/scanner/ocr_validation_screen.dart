import 'package:flutter/material.dart';
import '../../widgets/currency_input_field.dart';
import '../navigation/main_navigation_screen.dart';

class OcrValidationScreen extends StatefulWidget {
  final String imagePath;
  const OcrValidationScreen({super.key, required this.imagePath});

  @override
  State<OcrValidationScreen> createState() => _OcrValidationScreenState();
}

class _OcrValidationScreenState extends State<OcrValidationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form Field Controllers pre-populated with OCR scanned values
  late TextEditingController _storeNameController;
  late TextEditingController _addressController;
  DateTime _selectedDate = DateTime(2026, 6, 13);
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 30);

  // Scanned item list (with default/partially read values for correction)
  late List<Map<String, dynamic>> _items;
  double _tax = 2000.0; // pre-populated scanned tax

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController(text: 'Warung Kopi Jember');
    _addressController = TextEditingController(text: 'Jl. Gajah Mada No. 123');

    // Scanned items from ML Kit (mocked)
    _items = [
      {
        'name': 'Kopi Latte',
        'qty': 1,
        'price': 15000.0,
      },
      {
        'name': 'Roti Tawar',
        'qty': 2,
        'price': 7500.0,
      },
      {
        'name': '[Item Kurang Jelas]', // user can fix this
        'qty': 1,
        'price': 10000.0,
      },
    ];
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Calculated values
  double get _subtotal => _items.fold(0.0, (sum, item) => sum + (item['qty'] * item['price']));
  double get _total => _subtotal + _tax;

  // Add/Edit Item Modal Dialog
  void _showItemDialog({int? index}) {
    final bool isEdit = index != null;
    final Map<String, dynamic> itemData = isEdit
        ? Map<String, dynamic>.from(_items[index])
        : {'name': '', 'qty': 1, 'price': 0.0};

    final nameController = TextEditingController(text: itemData['name']);
    final priceController = TextEditingController(text: itemData['price'].toInt().toString());
    int qty = itemData['qty'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF141E2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                isEdit ? 'Edit Item Transaksi' : 'Tambah Item Baru',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nama Barang', style: TextStyle(color: Color(0xFF8A99AD), fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0B1220),
                        hintText: 'Contoh: Kopi Latte',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Qty increment/decrement selector
                    const Text('Quantity', style: TextStyle(color: Color(0xFF8A99AD), fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF00E5A8)),
                          onPressed: () {
                            if (qty > 1) {
                              setModalState(() => qty--);
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '$qty',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00E5A8)),
                          onPressed: () {
                            setModalState(() => qty++);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price input
                    const Text('Harga Satuan', style: TextStyle(color: Color(0xFF8A99AD), fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(color: Color(0xFF00E5A8), fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: const Color(0xFF0B1220),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
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
                    if (nameController.text.trim().isEmpty) return;
                    final double pr = double.tryParse(priceController.text) ?? 0.0;

                    setState(() {
                      if (isEdit) {
                        _items[index] = {
                          'name': nameController.text.trim(),
                          'qty': qty,
                          'price': pr,
                        };
                      } else {
                        _items.add({
                          'name': nameController.text.trim(),
                          'qty': qty,
                          'price': pr,
                        });
                      }
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5A8)),
                  child: const Text('Simpan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Delete Item Confirmation
  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141E2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Hapus Item', style: TextStyle(color: Colors.white)),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Save Transaction trigger
  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil disimpan!'),
          backgroundColor: Color(0xFF0C2B29),
        ),
      );

      // Navigate back to Dashboard Screen (root of Navigation Screen)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        title: const Text(
          'Validasi Hasil Pemindaian',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5A8)),
                ),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // OCR Scanning Source Preview banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E1724),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1F2E46)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.document_scanner, color: Color(0xFF00E5A8), size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Pindai OCR Selesai',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Silakan periksa dan koreksi data sebelum disimpan.',
                                    style: TextStyle(color: Color(0xFF8A99AD), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Text(
                        'INFORMASI TRANSAKSI',
                        style: TextStyle(color: Color(0xFF8A99AD), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 16),

                      // Store Name field
                      const Text('Nama Toko', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _storeNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration(hint: 'Masukkan nama toko', icon: Icons.store),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Nama toko wajib diisi' : null,
                      ),
                      const SizedBox(height: 18),

                      // Address field
                      const Text('Alamat Toko', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration(hint: 'Masukkan alamat toko', icon: Icons.location_on_outlined),
                      ),
                      const SizedBox(height: 18),

                      // Date & Time rows
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tanggal', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final selected = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (selected != null) {
                                      setState(() => _selectedDate = selected);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF141E2E),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFF1F2E46)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(color: Colors.white)),
                                        const Icon(Icons.calendar_today, color: Color(0xFF00E5A8), size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Waktu', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final selected = await showTimePicker(
                                      context: context,
                                      initialTime: _selectedTime,
                                    );
                                    if (selected != null) {
                                      setState(() => _selectedTime = selected);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF141E2E),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFF1F2E46)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_selectedTime.format(context), style: const TextStyle(color: Colors.white)),
                                        const Icon(Icons.access_time, color: Color(0xFF00E5A8), size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Item list editor section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'DETAIL ITEM TRANSAKSI',
                            style: TextStyle(color: Color(0xFF8A99AD), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                          GestureDetector(
                            onTap: () => _showItemDialog(),
                            child: const Text(
                              '+ Tambah Item',
                              style: TextStyle(color: Color(0xFF00E5A8), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_items.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text('Belum ada item ditambahkan', style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          itemBuilder: (context, idx) {
                            final item = _items[idx];
                            final totalItemPrice = item['qty'] * item['price'];

                            // Check if item looks incomplete (such as a placeholder/blur item from OCR)
                            final bool isIncomplete = item['name'].contains('[') || item['price'] <= 0;

                            return Card(
                              color: const Color(0xFF141E2E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isIncomplete ? Colors.orangeAccent.withOpacity(0.5) : const Color(0xFF1F2E46),
                                  width: isIncomplete ? 1.5 : 1,
                                ),
                              ),
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['name'],
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ),
                                    if (isIncomplete)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B2E1A),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Koreksi',
                                          style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${item['qty']} x Rp ${item['price'].toInt()} = Rp ${totalItemPrice.toInt()}',
                                    style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 12),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Color(0xFF00E5A8), size: 20),
                                      onPressed: () => _showItemDialog(index: idx),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () => _deleteItem(idx),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 28),

                      // Tax / Fee input
                      CurrencyInputField(
                        label: 'Pajak / Fee',
                        placeholder: 'Masukkan pajak jika ada',
                        initialValue: _tax.toInt().toString(),
                        onChanged: (val) {
                          setState(() {
                            _tax = double.tryParse(val) ?? 0.0;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Calculation summary card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141E2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1F2E46)),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow('Subtotal', 'Rp ${_subtotal.toInt()}'),
                            const SizedBox(height: 10),
                            _buildSummaryRow('Pajak / Fee', 'Rp ${_tax.toInt()}'),
                            const Divider(color: Color(0xFF1F2E46), height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('GRAND TOTAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(
                                  'Rp ${_total.toInt()}',
                                  style: const TextStyle(color: Color(0xFF00E5A8), fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: _isLoading
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF141E2E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1F2E46)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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
            ),
    );
  }

  Widget _buildSummaryRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 13)),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF141E2E),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
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
