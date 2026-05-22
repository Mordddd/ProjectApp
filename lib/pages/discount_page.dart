import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});

  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  final priceController = TextEditingController();
  final discountController = TextEditingController();

  String result = '';

  final primaryColor = const Color(0xFF082052);
  final bgColor = const Color(0xFFF8F0E5);

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void calculateDiscount() {
    final price = double.tryParse(
      priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    final discount = double.tryParse(discountController.text);

    if (price == null || discount == null) {
      setState(() {
        result = 'Masukkan angka yang valid!';
      });
      return;
    }

    final discountAmount = price * (discount / 100);
    final finalPrice = price - discountAmount;

    setState(() {
      result = '''
Harga Awal: ${formatRupiah.format(price)}
Diskon: $discount%
Potongan: ${formatRupiah.format(discountAmount)}
Harga Akhir: ${formatRupiah.format(finalPrice)}
''';
    });
  }

  void reset() {
    priceController.clear();
    discountController.clear();
    setState(() {
      result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Kalkulator Diskon'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔹 Card Input
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        String newValue =
                            value.replaceAll(RegExp(r'[^0-9]'), '');

                        if (newValue.isEmpty) {
                          priceController.text = '';
                          return;
                        }

                        final number = int.parse(newValue);
                        final formatted = formatRupiah.format(number);

                        priceController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: formatted.length,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Diskon (%)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: calculateDiscount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Hitung'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: reset,
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Result Card
            if (result.isNotEmpty)
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hasil Perhitungan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      Text(
                        result,
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}