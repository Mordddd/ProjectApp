enum PermissionFeature {
  profile,
  quiz,
  multiQuiz,
  calculator,
  maxMin,
  discount,
  bilangan,
  sorting,
  polling,
  zodiac,
  createAccount,
  viewAllProfiles,
}

extension PermissionFeatureLabel on PermissionFeature {
  String get label {
    switch (this) {
      case PermissionFeature.profile:
        return 'Profile';
      case PermissionFeature.quiz:
        return 'Quiz';
      case PermissionFeature.multiQuiz:
        return 'Multi Quiz';
      case PermissionFeature.calculator:
        return 'Calculator';
      case PermissionFeature.maxMin:
        return 'Max & Min';
      case PermissionFeature.discount:
        return 'Discount';
      case PermissionFeature.bilangan:
        return 'Bilangan';
      case PermissionFeature.sorting:
        return 'Sorting';
      case PermissionFeature.polling:
        return 'Polling';
      case PermissionFeature.zodiac:
        return 'Zodiac';
      case PermissionFeature.createAccount:
        return 'Create Account';
      case PermissionFeature.viewAllProfiles:
        return 'Lihat Semua Profile';
    }
  }
}
