import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_components.dart';

class PollPage extends StatefulWidget {
  const PollPage({super.key});

  @override
  State<PollPage> createState() => _PollPageState();
}

class _PollPageState extends State<PollPage> {
  final List<Map<String, dynamic>> _hobbies = [
    {
      'name': 'Badminton',
      'icon': Icons.sports_tennis,
      'color': const Color(0xFF10B981),
    },
    {'name': 'Catur', 'icon': Icons.grid_3x3, 'color': const Color(0xFF6366F1)},
    {
      'name': 'Padel',
      'icon': Icons.sports_tennis,
      'color': const Color(0xFFF59E0B),
    },
    {
      'name': 'Basket',
      'icon': Icons.sports_basketball,
      'color': const Color(0xFFEF4444),
    },
    {
      'name': 'Lari Marathon',
      'icon': Icons.directions_run,
      'color': AppPalette.navy,
    },
  ];

  String? _selectedHobby;
  bool _hasVoted = false;

  void _selectHobby(String hobby) {
    if (_hasVoted) return;
    setState(() {
      _selectedHobby = hobby;
    });
  }

  void _submitVote() {
    if (_selectedHobby == null) return;
    setState(() {
      _hasVoted = true;
    });
  }

  void _resetPoll() {
    setState(() {
      _selectedHobby = null;
      _hasVoted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Polling Hobi'),
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Card
            Card(
              color: AppPalette.navy,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.poll_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Polling Hobi Favorit',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pilih hobi favorit kamu!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Poll Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apa hobi favoritmu?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Pilih satu dari pilihan berikut:',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 20),

                    // Radio Options
                    ...List.generate(_hobbies.length, (index) {
                      final hobby = _hobbies[index];
                      final isSelected = _selectedHobby == hobby['name'];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: isSelected
                              ? (hobby['color'] as Color).withValues(alpha: 0.1)
                              : (theme.cardTheme.color ?? colors.surface),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => _selectHobby(hobby['name']),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? hobby['color']
                                      : colors.outlineVariant,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 160),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? hobby['color']
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? hobby['color']
                                            : colors.outline,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (hobby['color'] as Color)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      hobby['icon'],
                                      color: hobby['color'],
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      hobby['name'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? hobby['color']
                                            : colors.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (isSelected && !_hasVoted)
                                    Icon(
                                      Icons.check_circle,
                                      color: hobby['color'],
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Submit Button
                    if (!_hasVoted)
                      CustomButton(
                        text: 'Kirim Pilihan',
                        icon: Icons.send_rounded,
                        onPressed: _selectedHobby != null ? _submitVote : () {},
                        width: double.infinity,
                        backgroundColor: _selectedHobby != null
                            ? AppPalette.navy
                            : Colors.grey,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Result Card
            if (_hasVoted)
              Card(
                color: isDark
                    ? const Color(0xFF064E3B)
                    : const Color(0xFFD1FAE5),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 48,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Terima kasih telah voting!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF065F46),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Pilihan kamu: ',
                              style: TextStyle(
                                fontSize: 16,
                                color: colors.onSurface,
                              ),
                            ),
                            Text(
                              _selectedHobby!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _hobbies.firstWhere(
                                (h) => h['name'] == _selectedHobby,
                              )['icon'],
                              color: const Color(0xFF10B981),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Reset Button
            if (_hasVoted)
              CustomButton(
                text: 'Vote Ulang',
                icon: Icons.refresh_rounded,
                onPressed: _resetPoll,
                isOutlined: true,
                width: double.infinity,
              ),
          ],
        ),
      ),
    );
  }
}
