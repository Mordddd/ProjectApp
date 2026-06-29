import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../widgets/app_components.dart';

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

  final primaryColor = AppPalette.navy;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      history = prefs.getStringList('history') ?? [];
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> saveHistory(String data) async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => history.insert(0, data));
    await prefs.setStringList('history', history);
  }

  void calculate() {
    final parsed = controller.text
        .split('\n')
        .map((e) => double.tryParse(e.trim()))
        .whereType<double>()
        .toList();

    if (parsed.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Masukkan angka!")));
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
                color: primaryColor.withValues(alpha: 0.16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> exportCSV() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/data.csv");

    String csv = "index,value\n";

    for (int i = 0; i < numbers.length; i++) {
      csv += "$i,${numbers[i]}\n";
    }

    await file.writeAsString(csv);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("CSV tersimpan di: ${file.path}")));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text("Data Analyzer")),
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
                    icon: Icons.analytics_rounded,
                    color: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Data Analyzer",
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
                    controller: controller,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: "Masukkan angka (1 per baris)",
                    ),
                  ),
                  const SizedBox(height: 14),
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
            const SizedBox(height: 20),
            if (numbers.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(label: "Max", value: "$max"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(label: "Min", value: "$min"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      label: "Avg",
                      value: avg!.toStringAsFixed(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              CustomCard(child: buildLineChart()),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: exportCSV,
                icon: const Icon(Icons.download_rounded),
                label: const Text("Export CSV"),
              ),
              const SizedBox(height: 18),
              CustomCard(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: numbers.map((n) {
                    Color color = AppPalette.navy;

                    if (n == max) color = Colors.green;
                    if (n == min) color = Colors.red;

                    return Chip(
                      label: Text(n.toString()),
                      backgroundColor: color.withValues(alpha: 0.16),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 30),
            if (history.isNotEmpty) ...[
              SectionHeader(title: "Riwayat"),
              const SizedBox(height: 10),
              ...history.map(
                (h) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          color: AppPalette.navy,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(h)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppPalette.navy,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
