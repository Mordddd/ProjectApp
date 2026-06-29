import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/app_database.dart';
import '../config/supabase_config.dart';
import '../services/zodiac_repository.dart';
import '../widgets/app_components.dart';

class ZodiacPage extends StatefulWidget {
  final AppDatabase? database;

  const ZodiacPage({super.key, this.database});

  @override
  State<ZodiacPage> createState() => _ZodiacPageState();
}

class _ZodiacPageState extends State<ZodiacPage> {
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();

  late final ZodiacRepository _repository;
  AppDatabase? _ownedDatabase;
  late final bool _ownsDatabase;

  ZodiacResult? _selectedResult;
  int? _editingRecordId;

  static const _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const _daysInMonth = {
    1: 31,
    2: 29,
    3: 31,
    4: 30,
    5: 31,
    6: 30,
    7: 31,
    8: 31,
    9: 30,
    10: 31,
    11: 30,
    12: 31,
  };

  static const _zodiacs = [
    ZodiacInfo(
      name: 'Capricorn',
      startMonth: 12,
      startDay: 22,
      endMonth: 1,
      endDay: 19,
      character:
          'Disiplin, ambisius, realistis, dan kuat dalam menjaga komitmen.',
      strengths: 'Bertanggung jawab, sabar, pekerja keras, dan terencana.',
      weaknesses: 'Kadang terlalu serius, kaku, atau sulit menerima perubahan.',
      compatible: 'Taurus, Virgo, Scorpio, Pisces',
      lessCompatible: 'Aries, Libra, Gemini',
      element: 'Tanah',
      symbol: 'Kambing laut',
      accent: Color(0xFF123D73),
    ),
    ZodiacInfo(
      name: 'Aquarius',
      startMonth: 1,
      startDay: 20,
      endMonth: 2,
      endDay: 18,
      character:
          'Mandiri, visioner, humanis, dan menyukai ide yang tidak biasa.',
      strengths: 'Kreatif, terbuka, objektif, dan peduli pada lingkungan.',
      weaknesses:
          'Bisa terlihat dingin, keras kepala, atau terlalu menjaga jarak.',
      compatible: 'Gemini, Libra, Aries, Sagittarius',
      lessCompatible: 'Taurus, Scorpio, Cancer',
      element: 'Udara',
      symbol: 'Pembawa air',
      accent: Color(0xFF0EA5E9),
    ),
    ZodiacInfo(
      name: 'Pisces',
      startMonth: 2,
      startDay: 19,
      endMonth: 3,
      endDay: 20,
      character:
          'Intuitif, penyayang, imajinatif, dan mudah memahami perasaan orang.',
      strengths: 'Empatik, artistik, lembut, dan mudah beradaptasi.',
      weaknesses: 'Mudah terbawa suasana, ragu-ragu, atau terlalu sensitif.',
      compatible: 'Cancer, Scorpio, Taurus, Capricorn',
      lessCompatible: 'Gemini, Sagittarius, Libra',
      element: 'Air',
      symbol: 'Ikan',
      accent: Color(0xFF6366F1),
    ),
    ZodiacInfo(
      name: 'Aries',
      startMonth: 3,
      startDay: 21,
      endMonth: 4,
      endDay: 19,
      character:
          'Berani, energik, kompetitif, dan senang memulai tantangan baru.',
      strengths: 'Percaya diri, spontan, jujur, dan cepat mengambil tindakan.',
      weaknesses: 'Impulsif, kurang sabar, dan kadang mudah terpancing emosi.',
      compatible: 'Leo, Sagittarius, Gemini, Aquarius',
      lessCompatible: 'Cancer, Capricorn, Virgo',
      element: 'Api',
      symbol: 'Domba jantan',
      accent: Color(0xFFEF4444),
    ),
    ZodiacInfo(
      name: 'Taurus',
      startMonth: 4,
      startDay: 20,
      endMonth: 5,
      endDay: 20,
      character:
          'Stabil, setia, praktis, dan menikmati kenyamanan hidup yang terukur.',
      strengths: 'Konsisten, dapat diandalkan, sabar, dan tekun.',
      weaknesses:
          'Keras kepala, posesif, dan kadang sulit keluar dari rutinitas.',
      compatible: 'Virgo, Capricorn, Cancer, Pisces',
      lessCompatible: 'Leo, Aquarius, Sagittarius',
      element: 'Tanah',
      symbol: 'Banteng',
      accent: Color(0xFF22C55E),
    ),
    ZodiacInfo(
      name: 'Gemini',
      startMonth: 5,
      startDay: 21,
      endMonth: 6,
      endDay: 20,
      character: 'Cerdas, komunikatif, penasaran, dan mudah menyesuaikan diri.',
      strengths: 'Cepat belajar, ramah, fleksibel, dan penuh ide.',
      weaknesses: 'Mudah bosan, tidak konsisten, atau terlalu banyak berpikir.',
      compatible: 'Libra, Aquarius, Aries, Leo',
      lessCompatible: 'Virgo, Pisces, Capricorn',
      element: 'Udara',
      symbol: 'Anak kembar',
      accent: Color(0xFFF59E0B),
    ),
    ZodiacInfo(
      name: 'Cancer',
      startMonth: 6,
      startDay: 21,
      endMonth: 7,
      endDay: 22,
      character:
          'Penyayang, protektif, intuitif, dan sangat menghargai keluarga.',
      strengths: 'Setia, perhatian, empatik, dan kuat menjaga hubungan.',
      weaknesses: 'Mudah tersinggung, moody, dan kadang terlalu protektif.',
      compatible: 'Scorpio, Pisces, Taurus, Virgo',
      lessCompatible: 'Aries, Libra, Aquarius',
      element: 'Air',
      symbol: 'Kepiting',
      accent: Color(0xFF06B6D4),
    ),
    ZodiacInfo(
      name: 'Leo',
      startMonth: 7,
      startDay: 23,
      endMonth: 8,
      endDay: 22,
      character:
          'Percaya diri, hangat, ekspresif, dan senang memberi energi positif.',
      strengths: 'Murah hati, kreatif, berani, dan memiliki jiwa pemimpin.',
      weaknesses: 'Butuh pengakuan, dominan, atau kadang terlalu dramatis.',
      compatible: 'Aries, Sagittarius, Gemini, Libra',
      lessCompatible: 'Taurus, Scorpio, Capricorn',
      element: 'Api',
      symbol: 'Singa',
      accent: Color(0xFFF97316),
    ),
    ZodiacInfo(
      name: 'Virgo',
      startMonth: 8,
      startDay: 23,
      endMonth: 9,
      endDay: 22,
      character:
          'Teliti, analitis, sederhana, dan suka memperbaiki hal secara detail.',
      strengths: 'Rapi, logis, rajin, dan sangat membantu.',
      weaknesses: 'Perfeksionis, mudah khawatir, atau terlalu kritis.',
      compatible: 'Taurus, Capricorn, Cancer, Scorpio',
      lessCompatible: 'Gemini, Sagittarius, Aries',
      element: 'Tanah',
      symbol: 'Gadis',
      accent: Color(0xFF14B8A6),
    ),
    ZodiacInfo(
      name: 'Libra',
      startMonth: 9,
      startDay: 23,
      endMonth: 10,
      endDay: 22,
      character:
          'Diplomatis, harmonis, ramah, dan menghargai keadilan dalam hubungan.',
      strengths: 'Bijaksana, mudah bekerja sama, romantis, dan seimbang.',
      weaknesses:
          'Sulit mengambil keputusan, menghindari konflik, atau plin-plan.',
      compatible: 'Gemini, Aquarius, Leo, Sagittarius',
      lessCompatible: 'Cancer, Capricorn, Pisces',
      element: 'Udara',
      symbol: 'Timbangan',
      accent: Color(0xFFEC4899),
    ),
    ZodiacInfo(
      name: 'Scorpio',
      startMonth: 10,
      startDay: 23,
      endMonth: 11,
      endDay: 21,
      character: 'Intens, fokus, misterius, dan memiliki intuisi yang tajam.',
      strengths: 'Setia, berani, tekun, dan kuat secara emosional.',
      weaknesses: 'Cemburuan, sulit percaya, atau terlalu menyimpan perasaan.',
      compatible: 'Cancer, Pisces, Virgo, Capricorn',
      lessCompatible: 'Leo, Aquarius, Gemini',
      element: 'Air',
      symbol: 'Kalajengking',
      accent: Color(0xFF7C3AED),
    ),
    ZodiacInfo(
      name: 'Sagittarius',
      startMonth: 11,
      startDay: 22,
      endMonth: 12,
      endDay: 21,
      character:
          'Optimis, petualang, jujur, dan menyukai kebebasan untuk berkembang.',
      strengths: 'Berpikiran terbuka, humoris, antusias, dan berani mencoba.',
      weaknesses: 'Terlalu blak-blakan, gelisah, atau kurang detail.',
      compatible: 'Aries, Leo, Libra, Aquarius',
      lessCompatible: 'Virgo, Pisces, Taurus',
      element: 'Api',
      symbol: 'Pemanah',
      accent: Color(0xFF10B981),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ownsDatabase = widget.database == null && !SupabaseConfig.isConfigured;
    if (widget.database != null) {
      _repository = LocalZodiacRepository(widget.database!);
    } else if (SupabaseConfig.isConfigured) {
      _repository = SupabaseZodiacRepository(SupabaseConfig.client);
    } else {
      _ownedDatabase = AppDatabase();
      _repository = LocalZodiacRepository(_ownedDatabase!);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  _BirthDate? _readBirthDate() {
    final dayText = _dayController.text.trim();
    final monthText = _monthController.text.trim();

    if (dayText.isEmpty || monthText.isEmpty) {
      _showSnack('Tanggal dan bulan lahir tidak boleh kosong.');
      return null;
    }

    final day = int.tryParse(dayText);
    final month = int.tryParse(monthText);

    if (day == null || month == null) {
      _showSnack('Tanggal dan bulan harus berupa angka.');
      return null;
    }

    if (month < 1 || month > 12) {
      _showSnack('Bulan harus berada di antara 1 sampai 12.');
      return null;
    }

    final maxDay = _daysInMonth[month]!;
    if (day < 1 || day > maxDay) {
      _showSnack(
        'Tanggal untuk bulan ${_monthNames[month - 1]} harus 1 sampai $maxDay.',
      );
      return null;
    }

    return _BirthDate(day: day, month: month);
  }

  Future<void> _findZodiac() async {
    final birthDate = _readBirthDate();
    if (birthDate == null) return;

    final zodiac = _zodiacs.firstWhere(
      (item) => item.matches(day: birthDate.day, month: birthDate.month),
    );
    final result = zodiac.toResult();

    try {
      final editingId = _editingRecordId;
      if (editingId == null) {
        await _repository.createZodiacRecord(
          result.toCompanion(day: birthDate.day, month: birthDate.month),
        );
        if (!mounted) return;
        _showSnack('Data zodiac disimpan ke ${_repository.storageLabel}.');
      } else {
        await _repository.updateZodiacRecord(
          id: editingId,
          record: result.toCompanion(
            day: birthDate.day,
            month: birthDate.month,
          ),
        );
        if (!mounted) return;
        _showSnack('Data riwayat zodiac diperbarui.');
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack('Gagal menyimpan data zodiac ke database.');
      return;
    }

    FocusScope.of(context).unfocus();
    if (!mounted) return;
    setState(() {
      _selectedResult = result;
      _editingRecordId = null;
    });
  }

  void _selectRecord(ZodiacRecord record) {
    _dayController.text = record.day.toString();
    _monthController.text = record.month.toString();
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedResult = ZodiacResult.fromRecord(record);
      _editingRecordId = null;
    });
  }

  void _startEditing(ZodiacRecord record) {
    _dayController.text = record.day.toString();
    _monthController.text = record.month.toString();
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedResult = ZodiacResult.fromRecord(record);
      _editingRecordId = record.id;
    });
    _showSnack('Mode edit aktif. Ubah tanggal/bulan lalu tekan Update Data.');
  }

  Future<void> _deleteRecord(ZodiacRecord record) async {
    await _repository.deleteZodiacRecord(record.id);
    if (!mounted) return;

    if (_editingRecordId == record.id) {
      _reset(showMessage: false);
    }

    _showSnack(
      'Riwayat ${record.zodiacName} dihapus dari ${_repository.storageLabel}.',
    );
  }

  void _reset({bool showMessage = true}) {
    FocusScope.of(context).unfocus();
    _dayController.clear();
    _monthController.clear();
    setState(() {
      _selectedResult = null;
      _editingRecordId = null;
    });

    if (showMessage) {
      _showSnack('Form zodiac direset.');
    }
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    if (_ownsDatabase) {
      _ownedDatabase?.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEditing = _editingRecordId != null;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Zodiac')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeaderCard(),
            const SizedBox(height: 18),
            _InputCard(
              dayController: _dayController,
              monthController: _monthController,
              isEditing: isEditing,
              onSubmit: _findZodiac,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _findZodiac,
                    icon: Icon(
                      isEditing
                          ? Icons.save_rounded
                          : Icons.auto_awesome_rounded,
                    ),
                    label: Text(isEditing ? 'Update Data' : 'Cek & Simpan'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reset'),
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _selectedResult == null
                  ? const SizedBox.shrink()
                  : Padding(
                      key: ValueKey(_selectedResult!.name),
                      padding: const EdgeInsets.only(top: 20),
                      child: _ZodiacResultCard(result: _selectedResult!),
                    ),
            ),
            const SizedBox(height: 20),
            _HistorySection(
              repository: _repository,
              onSelect: _selectRecord,
              onEdit: _startEditing,
              onDelete: _deleteRecord,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      color: AppPalette.navy,
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      child: Row(
        children: [
          IconBubble(
            icon: Icons.auto_awesome_rounded,
            color: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cari Zodiac Kamu',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Data hasil pengecekan akan tersimpan sebagai riwayat SQLite.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.76),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final TextEditingController dayController;
  final TextEditingController monthController;
  final bool isEditing;
  final VoidCallback onSubmit;

  const _InputCard({
    required this.dayController,
    required this.monthController,
    required this.isEditing,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tanggal Lahir',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (isEditing)
                Chip(
                  avatar: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Mode edit'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: dayController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    hintText: '1-31',
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: monthController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onSubmit(),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Bulan',
                    hintText: '1-12',
                    prefixIcon: Icon(Icons.event_rounded),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ZodiacResultCard extends StatelessWidget {
  final ZodiacResult result;

  const _ZodiacResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: result.accent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                IconBubble(
                  icon: Icons.stars_rounded,
                  color: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  size: 58,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${result.dateRange} - ${result.element}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.psychology_rounded,
                  label: 'Sifat umum',
                  value: result.character,
                  color: result.accent,
                ),
                _InfoRow(
                  icon: Icons.trending_up_rounded,
                  label: 'Kelebihan',
                  value: result.strengths,
                  color: result.accent,
                ),
                _InfoRow(
                  icon: Icons.report_problem_rounded,
                  label: 'Kekurangan',
                  value: result.weaknesses,
                  color: result.accent,
                ),
                _InfoRow(
                  icon: Icons.favorite_rounded,
                  label: 'Pasangan cocok',
                  value: result.compatible,
                  color: result.accent,
                ),
                _InfoRow(
                  icon: Icons.heart_broken_rounded,
                  label: 'Kurang cocok',
                  value: result.lessCompatible,
                  color: result.accent,
                ),
                _InfoRow(
                  icon: Icons.public_rounded,
                  label: 'Elemen',
                  value: result.element,
                  color: result.accent,
                ),
                _InfoRow(
                  icon: Icons.token_rounded,
                  label: 'Simbol',
                  value: result.symbol,
                  color: result.accent,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  final ZodiacRepository repository;
  final ValueChanged<ZodiacRecord> onSelect;
  final ValueChanged<ZodiacRecord> onEdit;
  final Future<void> Function(ZodiacRecord record) onDelete;

  const _HistorySection({
    required this.repository,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<ZodiacRecord>>(
      stream: repository.watchZodiacRecords(),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const <ZodiacRecord>[];

        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBubble(
                    icon: Icons.storage_rounded,
                    color: AppPalette.navy,
                    size: 42,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat ${repository.storageLabel}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${records.length} data tersimpan',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (records.isEmpty)
                Text(
                  'Belum ada riwayat. Cek zodiac untuk membuat data baru.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                ...records.map((record) {
                  final index = records.indexOf(record);
                  return _HistoryItem(
                    record: record,
                    showDivider: index != records.length - 1,
                    onTap: () => onSelect(record),
                    onEdit: () => onEdit(record),
                    onDelete: () => onDelete(record),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final ZodiacRecord record;
  final bool showDivider;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HistoryItem({
    required this.record,
    required this.showDivider,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(record.accentValue);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  IconBubble(
                    icon: Icons.auto_awesome_rounded,
                    color: color,
                    size: 42,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.zodiacName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${record.day}/${record.month} - ${record.element} - '
                          '${_formatDate(record.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit ${record.zodiacName}',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    tooltip: 'Hapus ${record.zodiacName}',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool showDivider;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBubble(icon: icon, color: color, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.36),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
      ],
    );
  }
}

class _BirthDate {
  final int day;
  final int month;

  const _BirthDate({required this.day, required this.month});
}

class ZodiacInfo {
  final String name;
  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;
  final String character;
  final String strengths;
  final String weaknesses;
  final String compatible;
  final String lessCompatible;
  final String element;
  final String symbol;
  final Color accent;

  const ZodiacInfo({
    required this.name,
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
    required this.character,
    required this.strengths,
    required this.weaknesses,
    required this.compatible,
    required this.lessCompatible,
    required this.element,
    required this.symbol,
    required this.accent,
  });

  String get dateRange {
    return '$startDay ${_ZodiacPageState._monthNames[startMonth - 1]} - '
        '$endDay ${_ZodiacPageState._monthNames[endMonth - 1]}';
  }

  bool matches({required int day, required int month}) {
    final dateScore = month * 100 + day;
    final startScore = startMonth * 100 + startDay;
    final endScore = endMonth * 100 + endDay;

    if (startScore <= endScore) {
      return dateScore >= startScore && dateScore <= endScore;
    }

    return dateScore >= startScore || dateScore <= endScore;
  }

  ZodiacResult toResult() {
    return ZodiacResult(
      name: name,
      dateRange: dateRange,
      character: character,
      strengths: strengths,
      weaknesses: weaknesses,
      compatible: compatible,
      lessCompatible: lessCompatible,
      element: element,
      symbol: symbol,
      accent: accent,
    );
  }
}

class ZodiacResult {
  final String name;
  final String dateRange;
  final String character;
  final String strengths;
  final String weaknesses;
  final String compatible;
  final String lessCompatible;
  final String element;
  final String symbol;
  final Color accent;

  const ZodiacResult({
    required this.name,
    required this.dateRange,
    required this.character,
    required this.strengths,
    required this.weaknesses,
    required this.compatible,
    required this.lessCompatible,
    required this.element,
    required this.symbol,
    required this.accent,
  });

  factory ZodiacResult.fromRecord(ZodiacRecord record) {
    return ZodiacResult(
      name: record.zodiacName,
      dateRange: record.dateRange,
      character: record.character,
      strengths: record.strengths,
      weaknesses: record.weaknesses,
      compatible: record.compatible,
      lessCompatible: record.lessCompatible,
      element: record.element,
      symbol: record.symbol,
      accent: Color(record.accentValue),
    );
  }

  ZodiacRecordsCompanion toCompanion({required int day, required int month}) {
    return ZodiacRecordsCompanion.insert(
      day: day,
      month: month,
      zodiacName: name,
      dateRange: dateRange,
      character: character,
      strengths: strengths,
      weaknesses: weaknesses,
      compatible: compatible,
      lessCompatible: lessCompatible,
      element: element,
      symbol: symbol,
      accentValue: accent.toARGB32(),
      createdAt: Value(DateTime.now()),
    );
  }
}

String _formatDate(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');

  return '${twoDigits(value.day)}/${twoDigits(value.month)}/${value.year} '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}
