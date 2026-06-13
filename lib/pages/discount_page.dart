import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../widgets/app_components.dart';

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});

  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  final priceController = TextEditingController();
  final discountController = TextEditingController();

  String result = '';

  final primaryColor = AppPalette.navy;

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
      result =
          '''
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Kalkulator Diskon')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomCard(
              color: AppPalette.navy,
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              child: Row(
                children: [
                  IconBubble(
                    icon: Icons.discount_rounded,
                    color: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Kalkulator Diskon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            CustomCard(
              child: Column(
                children: [
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Harga'),
                    onChanged: (value) {
                      String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');

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
                    decoration: const InputDecoration(labelText: 'Diskon (%)'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
            if (result.isNotEmpty)
              CustomCard(
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
                      style: TextStyle(fontSize: 16, color: primaryColor),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
