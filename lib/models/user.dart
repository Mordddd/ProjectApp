class User {
  final String name;
  final String avatarUrl;
  final double learningProgress;
  final int completedCourses;
  final int completedQuizzes;

  const User({
    required this.name,
    required this.avatarUrl,
    required this.learningProgress,
    required this.completedCourses,
    required this.completedQuizzes,
  });

  static User defaultUser() {
    return const User(
      name: 'Admin',
      avatarUrl:
          '[api.dicebear.com](https://api.dicebear.com/7.x/avataaars/png?seed=learning)',
      learningProgress: 65.0,
      completedCourses: 12,
      completedQuizzes: 8,
    );
  }
}
