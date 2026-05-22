import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MaxMinPage extends StatefulWidget {
  const MaxMinPage({super.key});

  @override
  State<MaxMinPage> createState() => _MaxMinPageState();
}

class _MaxMinPageState extends State<MaxMinPage> {
  final TextEditingController controller = TextEditingController();

  List<double> numbers = [];
  double? max;
  double? min;
  double? avg;

  List<String> history = [];

  final primaryColor = const Color(0xFF082052);
  final bgColor = const Color(0xFFF8F0E5);

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // LOAD HISTORY
  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      history = prefs.getStringList('history') ?? [];
    });
  }

  // SAVE HISTORY
  Future<void> saveHistory(String data) async {
    final prefs = await SharedPreferences.getInstance();
    history.insert(0, data);
    await prefs.setStringList('history', history);
  }

  void calculate() {
    final parsed = controller.text
        .split('\n')
        .map((e) => double.tryParse(e.trim()))
        .whereType<double>()
        .toList();

    if (parsed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan angka!")),
      );
      return;
    }

    parsed.sort();

    setState(() {
      numbers = parsed;
      max = parsed.last;
      min = parsed.first;
      avg = parsed.reduce((a, b) => a + b) / parsed.length;
    });

    saveHistory(parsed.join(", "));
  }

  void reset() {
    controller.clear();
    setState(() {
      numbers = [];
      max = null;
      min = null;
      avg = null;
    });
  }

  // LINE CHART
  Widget buildLineChart() {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: numbers.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value);
              }).toList(),
              isCurved: true,
              color: primaryColor,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: primaryColor.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // EXPORT CSV
  Future<void> exportCSV() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/data.csv");

    String csv = "index,value\n";

    for (int i = 0; i < numbers.length; i++) {
      csv += "$i,${numbers[i]}\n";
    }

    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("CSV tersimpan di: ${file.path}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Data Analyzer"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // INPUT
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: controller,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: "Masukkan angka (1 per baris)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: calculate,
                            child: const Text("Hitung"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: reset,
                            child: const Text("Reset"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (numbers.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Max: $max"),
                  Text("Min: $min"),
                  Text("Avg: ${avg!.toStringAsFixed(2)}"),
                ],
              ),

              const SizedBox(height: 20),

              buildLineChart(),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: exportCSV,
                icon: const Icon(Icons.download),
                label: const Text("Export CSV"),
              ),

              const SizedBox(height: 20),

              Wrap(
                spacing: 8,
                children: numbers.map((n) {
                  Color color = Colors.blue;

                  if (n == max) color = Colors.green;
                  if (n == min) color = Colors.red;

                  return Chip(
                    label: Text(n.toString()),
                    backgroundColor: color.withOpacity(0.2),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 30),

            if (history.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Riwayat",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              ...history.map((h) => ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(h),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}