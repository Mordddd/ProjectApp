import 'package:flutter/material.dart';
import '../models/question.dart';
import '../widgets/option_tile.dart';
import '../widgets/custom_button.dart';

class MultiQuizPage extends StatefulWidget {
  const MultiQuizPage({super.key});

  @override
  State<MultiQuizPage> createState() => _MultiQuizPageState();
}

class _MultiQuizPageState extends State<MultiQuizPage> {
  final Question question = const Question(
    questionText: 'Pilih bahasa pemrograman yang populer untuk mobile development:',
    options: [
      'Dart',
      'HTML',
      'Kotlin',
      'CSS',
      'Swift',
    ],
    correctAnswerIndices: [0, 2, 4],
    isMultipleAnswer: true,
  );

  Set<int> selectedIndices = {};
  bool hasAnswered = false;

  void _toggleSelection(int index) {
    if (hasAnswered) return;

    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
      } else {
        selectedIndices.add(index);
      }
    });
  }

  void _submitAnswer() {
    if (selectedIndices.isEmpty) return;

    setState(() {
      hasAnswered = true;
    });
  }

  void _resetQuiz() {
    setState(() {
      selectedIndices = {};
      hasAnswered = false;
    });
  }

  OptionState _getOptionState(int index) {
    if (!hasAnswered) {
      return selectedIndices.contains(index)
          ? OptionState.selected
          : OptionState.normal;
    }

    final isCorrectOption = question.correctAnswerIndices.contains(index);
    final isSelected = selectedIndices.contains(index);

    if (isSelected && isCorrectOption) {
      return OptionState.correct;
    } else if (isSelected && !isCorrectOption) {
      return OptionState.incorrect;
    } else if (!isSelected && isCorrectOption) {
      return OptionState.correct;
    }

    return OptionState.normal;
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = hasAnswered &&
        question.checkAnswer(selectedIndices.toList());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Multi Quiz'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz Header
            Card(
              color: const Color(0xFFF59E0B),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.checklist_rounded,
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
                            'Multiple Answer Quiz',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pilih semua jawaban yang benar',
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

            // Question Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Pilihan Ganda',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      question.questionText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Options
                    ...List.generate(question.options.length, (index) {
                      return OptionTile(
                        text: question.options[index],
                        state: _getOptionState(index),
                        isMultiSelect: true,
                        isSelected: selectedIndices.contains(index),
                        onTap: () => _toggleSelection(index),
                      );
                    }),

                    if (!hasAnswered && selectedIndices.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Center(
                        child: CustomButton(
                          text: 'Submit Jawaban',
                          icon: Icons.send_rounded,
                          onPressed: _submitAnswer,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Result Card
            if (hasAnswered)
              Card(
                color: isCorrect
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFFEE2E2),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCorrect
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: isCorrect
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            isCorrect ? 'Benar! ✅' : 'Salah! ❌',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isCorrect
                                  ? const Color(0xFF065F46)
                                  : const Color(0xFF991B1B),
                            ),
                          ),
                        ],
                      ),
                      if (!isCorrect) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jawaban yang benar:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...question.correctAnswerIndices.map((i) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Color(0xFF10B981),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      question.options[i],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Reset Button
            if (hasAnswered)
              Center(
                child: CustomButton(
                  text: 'Coba Lagi',
                  icon: Icons.refresh_rounded,
                  onPressed: _resetQuiz,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
