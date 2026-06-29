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
  accessControl,
}

extension PermissionFeatureLabel on PermissionFeature {
  String get databaseKey {
    switch (this) {
      case PermissionFeature.multiQuiz:
        return 'multi_quiz';
      case PermissionFeature.maxMin:
        return 'max_min';
      case PermissionFeature.createAccount:
        return 'create_account';
      case PermissionFeature.viewAllProfiles:
        return 'view_all_profiles';
      case PermissionFeature.accessControl:
        return 'access_control';
      default:
        return name;
    }
  }

  static PermissionFeature? fromDatabaseKey(String value) {
    for (final feature in PermissionFeature.values) {
      if (feature.databaseKey == value) return feature;
    }
    return null;
  }

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
        return 'Browse Profiles';
      case PermissionFeature.accessControl:
        return 'Access Control';
    }
  }
}
