import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../config/supabase_config.dart';
import '../models/app_user.dart';
import '../models/class_poll_response.dart';
import '../services/class_poll_repository.dart';

class PollPage extends StatefulWidget {
  final AppUser? currentUser;
  final ClassPollRepository? repository;

  const PollPage({super.key, this.currentUser, this.repository});

  @override
  State<PollPage> createState() => _PollPageState();
}

class _PollPageState extends State<PollPage> {
  late final ClassPollRepository _repository;
  late final Stream<List<ClassPollResponse>> _responses;

  bool get _isAdmin => widget.currentUser?.levelUser.isAdmin ?? false;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ??
        (SupabaseConfig.isConfigured
            ? SupabaseClassPollRepository(SupabaseConfig.client)
            : MemoryClassPollRepository.seeded());
    _responses = _repository.watchResponses();
  }

  Future<void> _openResponseForm([ClassPollResponse? existing]) async {
    final result = await showModalBottomSheet<ClassPollResponse>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ResponseForm(existing: existing),
    );

    if (result == null || !mounted) return;
    try {
      if (existing == null) {
        await _repository.createResponse(result);
      } else {
        await _repository.updateResponse(result);
      }
      if (!mounted) return;
      final action = existing == null ? 'ditambahkan' : 'diperbarui';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Respons ${result.name} berhasil $action.')),
      );
    } catch (error) {
      if (!mounted) return;
      _showError('Gagal menyimpan respons', error);
    }
  }

  Future<void> _deleteResponse(ClassPollResponse response) async {
    final id = response.id;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus respons?'),
        content: Text('Data ${response.name} akan dihapus dari dashboard.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repository.deleteResponse(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Respons ${response.name} berhasil dihapus.')),
      );
    } catch (error) {
      if (!mounted) return;
      _showError('Gagal menghapus respons', error);
    }
  }

  void _showError(String title, Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title: $error')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Dashboard Kelas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                _repository.storageLabel,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openResponseForm,
        icon: const Icon(Icons.add_rounded),
        label: Text(_isAdmin ? 'Tambah data' : 'Isi polling'),
      ),
      body: StreamBuilder<List<ClassPollResponse>>(
        stream: _responses,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _LoadError(error: snapshot.error);
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final responses = snapshot.data!;
          if (responses.isEmpty) {
            return _EmptyState(onAdd: _openResponseForm);
          }
          return _buildDashboard(context, responses);
        },
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    List<ClassPollResponse> responses,
  ) {
    final colors = Theme.of(context).colorScheme;
    final averageWeight = responses.isEmpty
        ? 0
        : responses.map((e) => e.weight).reduce((a, b) => a + b) /
              responses.length;
    final averageHeight = responses.isEmpty
        ? 0
        : responses.map((e) => e.height).reduce((a, b) => a + b) /
              responses.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth >= 720 ? 32.0 : 18.0;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 104),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardHeader(
                    total: responses.length,
                    averageWeight: averageWeight.toDouble(),
                    averageHeight: averageHeight.toDouble(),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Lima sudut pandang kelas',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Setiap grafik memakai bentuk yang berbeda agar pola data lebih mudah dibaca.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 18),
                  _ChartGrid(responses: responses),
                  if (_isAdmin) ...[
                    const SizedBox(height: 32),
                    _AdminResponseList(
                      responses: responses,
                      onEdit: _openResponseForm,
                      onDelete: _deleteResponse,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final int total;
  final double averageWeight;
  final double averageHeight;

  const _DashboardHeader({
    required this.total,
    required this.averageWeight,
    required this.averageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        spacing: 32,
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil kelas dalam satu layar',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Kumpulkan data fisik dasar secara cepat, lalu lihat distribusinya langsung.',
                  style: TextStyle(
                    color: colors.onPrimary.withValues(alpha: 0.78),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          _Metric(label: 'Responden', value: '$total siswa'),
          _Metric(
            label: 'Rata-rata berat',
            value: '${averageWeight.toStringAsFixed(1)} kg',
          ),
          _Metric(
            label: 'Rata-rata tinggi',
            value: '${averageHeight.toStringAsFixed(1)} cm',
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return SizedBox(
      width: 142,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: onPrimary.withValues(alpha: .7))),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartGrid extends StatelessWidget {
  final List<ClassPollResponse> responses;

  const _ChartGrid({required this.responses});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 820;
        final width = wide
            ? (constraints.maxWidth - 18) / 2
            : constraints.maxWidth;
        final charts = <Widget>[
          _WeightChart(responses: responses),
          _HeightChart(responses: responses),
          _ShirtChart(responses: responses),
          _ShoeChart(responses: responses),
          _BloodChart(responses: responses),
        ];
        return Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            for (var i = 0; i < charts.length; i++)
              SizedBox(
                width: wide && i == charts.length - 1
                    ? constraints.maxWidth
                    : width,
                child: charts[i],
              ),
          ],
        );
      },
    );
  }
}

class _AdminResponseList extends StatelessWidget {
  final List<ClassPollResponse> responses;
  final ValueChanged<ClassPollResponse> onEdit;
  final ValueChanged<ClassPollResponse> onDelete;

  const _AdminResponseList({
    required this.responses,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kelola data responden',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            'Admin dapat memperbarui atau menghapus respons langsung dari aplikasi.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ...responses.map(
            (response) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: colors.surfaceContainerHighest.withValues(alpha: .55),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              response.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${response.weight.toStringAsFixed(1)} kg, '
                              '${response.height.toStringAsFixed(1)} cm, '
                              'baju ${response.shirtSize}, '
                              'sepatu ${response.shoeSize.toStringAsFixed(1)}, '
                              'darah ${response.bloodType}',
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit ${response.name}',
                        onPressed: () => onEdit(response),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Hapus ${response.name}',
                        onPressed: () => onDelete(response),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPanel extends StatelessWidget {
  final String title;
  final String caption;
  final String chartType;
  final Widget child;

  const _ChartPanel({
    required this.title,
    required this.caption,
    required this.chartType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 360,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      caption,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  chartType,
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<ClassPollResponse> responses;

  const _WeightChart({required this.responses});

  @override
  Widget build(BuildContext context) {
    const labels = ['<50', '50-59', '60-69', '70-79', '80+'];
    final values = List<int>.filled(labels.length, 0);
    for (final item in responses) {
      final index = item.weight < 50
          ? 0
          : item.weight < 60
          ? 1
          : item.weight < 70
          ? 2
          : item.weight < 80
          ? 3
          : 4;
      values[index]++;
    }
    final colors = Theme.of(context).colorScheme;
    return _ChartPanel(
      title: 'Berat badan',
      caption: 'Distribusi responden dalam kilogram',
      chartType: 'BAR',
      child: BarChart(
        BarChartData(
          maxY: math.max(4, values.reduce(math.max) + 1).toDouble(),
          alignment: BarChartAlignment.spaceAround,
          gridData: _grid(colors),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: true),
          titlesData: _bottomTitles(
            colors,
            (value) => labels[value.toInt().clamp(0, labels.length - 1)],
          ),
          barGroups: List.generate(
            values.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index].toDouble(),
                  width: 22,
                  color: colors.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeightChart extends StatelessWidget {
  final List<ClassPollResponse> responses;

  const _HeightChart({required this.responses});

  @override
  Widget build(BuildContext context) {
    final sorted = [...responses]..sort((a, b) => a.height.compareTo(b.height));
    final colors = Theme.of(context).colorScheme;
    final minimum = sorted.first.height - 8;
    final maximum = sorted.last.height + 8;
    return _ChartPanel(
      title: 'Tinggi badan',
      caption: 'Urutan tinggi dari terendah ke tertinggi',
      chartType: 'LINE',
      child: LineChart(
        LineChartData(
          minY: minimum.toDouble(),
          maxY: maximum.toDouble(),
          minX: 0,
          maxX: (sorted.length - 1).toDouble(),
          gridData: _grid(colors),
          borderData: FlBorderData(show: false),
          titlesData: _bottomTitles(colors, (value) => '${value.toInt() + 1}'),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                sorted.length,
                (index) => FlSpot(index.toDouble(), sorted[index].height),
              ),
              isCurved: true,
              color: colors.primary,
              barWidth: 3,
              dotData: FlDotData(show: sorted.length <= 16),
              belowBarData: BarAreaData(
                show: true,
                color: colors.primary.withValues(alpha: .1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShirtChart extends StatelessWidget {
  final List<ClassPollResponse> responses;

  const _ShirtChart({required this.responses});

  @override
  Widget build(BuildContext context) {
    const sizes = ['S', 'M', 'L', 'XL'];
    final scheme = Theme.of(context).colorScheme;
    final palette = [
      scheme.primary,
      scheme.primary.withValues(alpha: .78),
      scheme.primary.withValues(alpha: .56),
      scheme.primary.withValues(alpha: .34),
    ];
    final counts = {
      for (final size in sizes)
        size: responses.where((item) => item.shirtSize == size).length,
    };
    return _ChartPanel(
      title: 'Ukuran baju',
      caption: 'Komposisi ukuran seragam kelas',
      chartType: 'DONUT',
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 46,
                sectionsSpace: 3,
                sections: List.generate(
                  sizes.length,
                  (index) => PieChartSectionData(
                    value: counts[sizes[index]]!.toDouble(),
                    color: palette[index],
                    radius: 54,
                    showTitle: false,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              sizes.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, color: palette[index]),
                    const SizedBox(width: 8),
                    Text('${sizes[index]}  ${counts[sizes[index]]}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoeChart extends StatelessWidget {
  final List<ClassPollResponse> responses;

  const _ShoeChart({required this.responses});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _ChartPanel(
      title: 'Nomor sepatu',
      caption: 'Hubungan tinggi badan dan ukuran sepatu',
      chartType: 'SCATTER',
      child: ScatterChart(
        ScatterChartData(
          minX: 150,
          maxX: 188,
          minY: 34,
          maxY: 46,
          gridData: _grid(colors),
          borderData: FlBorderData(show: false),
          titlesData: _axisTitles(colors),
          scatterSpots: responses
              .map(
                (item) => ScatterSpot(
                  item.height,
                  item.shoeSize,
                  dotPainter: FlDotCirclePainter(
                    radius: 5,
                    color: colors.primary.withValues(alpha: .78),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _BloodChart extends StatelessWidget {
  final List<ClassPollResponse> responses;

  const _BloodChart({required this.responses});

  @override
  Widget build(BuildContext context) {
    const bloodTypes = ['A', 'B', 'AB', 'O'];
    final colors = Theme.of(context).colorScheme;
    final counts = bloodTypes
        .map(
          (type) => responses
              .where((response) => response.bloodType == type)
              .length
              .toDouble(),
        )
        .toList();
    return _ChartPanel(
      title: 'Golongan darah',
      caption: 'Perbandingan jumlah untuk kebutuhan data kelas',
      chartType: 'RADAR',
      child: RadarChart(
        RadarChartData(
          radarBackgroundColor: Colors.transparent,
          radarBorderData: BorderSide(color: colors.outlineVariant),
          gridBorderData: BorderSide(color: colors.outlineVariant),
          tickBorderData: BorderSide(color: colors.outlineVariant),
          ticksTextStyle: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 10,
          ),
          titleTextStyle: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
          getTitle: (index, angle) =>
              RadarChartTitle(text: bloodTypes[index], angle: angle),
          dataSets: [
            RadarDataSet(
              fillColor: colors.primary.withValues(alpha: .16),
              borderColor: colors.primary,
              borderWidth: 3,
              entryRadius: 4,
              dataEntries: counts
                  .map((value) => RadarEntry(value: value))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

FlGridData _grid(ColorScheme colors) => FlGridData(
  drawVerticalLine: false,
  getDrawingHorizontalLine: (_) => FlLine(
    color: colors.outlineVariant.withValues(alpha: .55),
    strokeWidth: 1,
  ),
);

FlTitlesData _bottomTitles(ColorScheme colors, String Function(double) label) =>
    FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 34,
          getTitlesWidget: (value, meta) => Text(
            value.toInt().toString(),
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 1,
          getTitlesWidget: (value, meta) => Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              label(value),
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
            ),
          ),
        ),
      ),
    );

FlTitlesData _axisTitles(ColorScheme colors) => FlTitlesData(
  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  leftTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 30,
      interval: 2,
      getTitlesWidget: (value, meta) => Text(
        value.toInt().toString(),
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10),
      ),
    ),
  ),
  bottomTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 28,
      interval: 10,
      getTitlesWidget: (value, meta) => Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Text(
          value.toInt().toString(),
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10),
        ),
      ),
    ),
  ),
);

class _ResponseForm extends StatefulWidget {
  final ClassPollResponse? existing;

  const _ResponseForm({this.existing});

  @override
  State<_ResponseForm> createState() => _ResponseFormState();
}

class _ResponseFormState extends State<_ResponseForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _weight;
  late final TextEditingController _height;
  late final TextEditingController _shoe;
  late String _shirt;
  late String _blood;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _weight = TextEditingController(
      text: existing == null ? '' : existing.weight.toStringAsFixed(1),
    );
    _height = TextEditingController(
      text: existing == null ? '' : existing.height.toStringAsFixed(1),
    );
    _shoe = TextEditingController(
      text: existing == null ? '' : existing.shoeSize.toStringAsFixed(1),
    );
    _shirt = existing?.shirtSize ?? 'M';
    _blood = existing?.bloodType ?? 'O';
  }

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _height.dispose();
    _shoe.dispose();
    super.dispose();
  }

  String? _numberValidator(String? value, double min, double max) {
    final number = double.tryParse(value ?? '');
    if (number == null) return 'Masukkan angka yang valid.';
    if (number < min || number > max) return 'Rentang valid $min sampai $max.';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      ClassPollResponse(
        id: widget.existing?.id,
        submittedBy: widget.existing?.submittedBy,
        name: _name.text.trim(),
        weight: double.parse(_weight.text),
        height: double.parse(_height.text),
        shirtSize: _shirt,
        shoeSize: double.parse(_shoe.text),
        bloodType: _blood,
        createdAt: widget.existing?.createdAt,
        updatedAt: widget.existing?.updatedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(22, 14, 22, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.existing == null
                  ? 'Isi polling kelas'
                  : 'Edit data responden',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              widget.existing == null
                  ? 'Data baru langsung disimpan dan memperbarui kelima grafik.'
                  : 'Perubahan akan langsung tersimpan dan memperbarui dashboard.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            _FieldLabel(
              label: 'Nama',
              child: TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Nama wajib diisi.'
                    : null,
              ),
            ),
            _FieldLabel(
              label: 'Berat badan (kg)',
              child: TextFormField(
                controller: _weight,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => _numberValidator(value, 30, 180),
              ),
            ),
            _FieldLabel(
              label: 'Tinggi badan (cm)',
              child: TextFormField(
                controller: _height,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => _numberValidator(value, 120, 220),
              ),
            ),
            _FieldLabel(
              label: 'Ukuran baju',
              child: DropdownButtonFormField<String>(
                initialValue: _shirt,
                items: ['S', 'M', 'L', 'XL']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _shirt = value ?? _shirt),
              ),
            ),
            _FieldLabel(
              label: 'Nomor sepatu',
              child: TextFormField(
                controller: _shoe,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => _numberValidator(value, 30, 50),
              ),
            ),
            _FieldLabel(
              label: 'Golongan darah',
              child: DropdownButtonFormField<String>(
                initialValue: _blood,
                items: ['A', 'B', 'AB', 'O']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _blood = value ?? _blood),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  widget.existing == null
                      ? 'Simpan respons'
                      : 'Simpan perubahan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldLabel({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

class _LoadError extends StatelessWidget {
  final Object? error;

  const _LoadError({required this.error});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Data polling belum dapat dimuat',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pastikan migrasi Supabase sudah diterapkan dan koneksi tersedia.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SelectableText(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_chart_outlined_rounded,
            size: 52,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data kelas',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text('Tambahkan respons pertama untuk mulai membuat grafik.'),
          const SizedBox(height: 20),
          FilledButton(onPressed: onAdd, child: const Text('Isi polling')),
        ],
      ),
    ),
  );
}
