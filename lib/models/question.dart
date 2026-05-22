class Question {
  final String questionText;
  final List<String> options;
  final List<int> correctAnswerIndices;
  final bool isMultipleAnswer;

  const Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndices,
    this.isMultipleAnswer = false,
  });

  bool checkAnswer(List<int> selectedIndices) {
    if (selectedIndices.length != correctAnswerIndices.length) {
      return false;
    }
    final sortedSelected = List<int>.from(selectedIndices)..sort();
    final sortedCorrect = List<int>.from(correctAnswerIndices)..sort();
    for (int i = 0; i < sortedSelected.length; i++) {
      if (sortedSelected[i] != sortedCorrect[i]) {
        return false;
      }
    }
    return true;
  }

  String getCorrectAnswersText() {
    return correctAnswerIndices.map((i) => options[i]).join(', ');
  }
}
