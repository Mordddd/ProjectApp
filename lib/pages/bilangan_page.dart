import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/app_components.dart';

class BilanganPage extends StatefulWidget {
  const BilanganPage({super.key});

  @override
  State<BilanganPage> createState() => _BilanganPageState();
}

class _BilanganPageState extends State<BilanganPage>
    with TickerProviderStateMixin {
  List<int> bilanganBulat = [];
  List<int> bilanganGanjil = [];
  List<int> fibonacci = [];
  List<String> loopLogs = [];

  bool ascending = true;

  final TextEditingController primeController = TextEditingController();

  String primeResult = '';

  final primaryColor = AppPalette.navy;

  @override
  void initState() {
    super.initState();

    generateBilanganBulat();
    generateBilanganGanjil();
    generateFibonacci();
  }

  // FOR
  void generateBilanganBulat() {
    bilanganBulat.clear();

    for (int i = 1; i <= 20; i++) {
      bilanganBulat.add(i);
      loopLogs.add("FOR -> i = $i");
    }
  }

  // WHILE
  void generateBilanganGanjil() {
    bilanganGanjil.clear();

    int i = 1;

    while (bilanganGanjil.length < 20) {
      bilanganGanjil.add(i);
      loopLogs.add("WHILE -> i = $i");
      i += 2;
    }
  }

  // DO WHILE
  void generateFibonacci() {
    fibonacci.clear();

    int a = 0;
    int b = 1;
    int count = 0;

    do {
      fibonacci.add(a);

      loopLogs.add("DO WHILE -> Fibonacci = $a");

      int temp = a + b;
      a = b;
      b = temp;

      count++;
    } while (count < 20);
  }

  // PRIME CHECKER
  void checkPrime() {
    final number = int.tryParse(primeController.text);

    if (number == null) {
      setState(() {
        primeResult = "Masukkan angka valid";
      });
      return;
    }

    bool isPrime = true;

    if (number <= 1) {
      isPrime = false;
    } else {
      for (int i = 2; i <= number ~/ 2; i++) {
        if (number % i == 0) {
          isPrime = false;
          break;
        }
      }
    }

    setState(() {
      primeResult = isPrime
          ? "$number adalah bilangan prima"
          : "$number bukan bilangan prima";
    });
  }

  // TOGGLE
  void toggleOrder() {
    setState(() {
      ascending = !ascending;

      bilanganBulat = bilanganBulat.reversed.toList();

      bilanganGanjil = bilanganGanjil.reversed.toList();

      fibonacci = fibonacci.reversed.toList();
    });
  }

  @override
  void dispose() {
    primeController.dispose();
    super.dispose();
  }

  // CHART
  Widget buildFibonacciChart() {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),

          lineBarsData: [
            LineChartBarData(
              spots: fibonacci.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.toDouble());
              }).toList(),

              isCurved: true,
              color: Colors.orange,
              barWidth: 4,

              dotData: FlDotData(show: true),

              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNumberSection(String title, List<int> data, Color color) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.asMap().entries.map((e) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (e.key * 50)),

                curve: Curves.easeInOut,

                child: Chip(
                  label: Text(
                    e.value.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text("Bilangan Lanjutan"),
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: toggleOrder,
        child: Icon(ascending ? Icons.arrow_downward : Icons.arrow_upward),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // PRIME CHECKER
            CustomCard(
              child: Column(
                children: [
                  const Text(
                    "Pemeriksa Bilangan Prima",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: primeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Masukkan angka",
                    ),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: checkPrime,
                    child: const Text("Cek Prima"),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    primeResult,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            buildNumberSection(
              "Bilangan Bulat (FOR)",
              bilanganBulat,
              Colors.blue,
            ),

            const SizedBox(height: 20),

            buildNumberSection(
              "Bilangan Ganjil (WHILE)",
              bilanganGanjil,
              Colors.green,
            ),

            const SizedBox(height: 20),

            buildNumberSection(
              "Fibonacci (DO WHILE)",
              fibonacci,
              Colors.orange,
            ),

            const SizedBox(height: 20),

            // CHART
            CustomCard(
              child: Column(
                children: [
                  const Text(
                    "Grafik Fibonacci",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),

                  const SizedBox(height: 20),

                  buildFibonacciChart(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // LOOP VISUALIZATION
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Visualisasi Loop",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),

                  const SizedBox(height: 12),

                  ...loopLogs
                      .take(20)
                      .map(
                        (log) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(log),
                        ),
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
