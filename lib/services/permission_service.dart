import '../models/app_user.dart';
import '../models/level_user.dart';
import '../models/permission.dart';

class PermissionService {
  PermissionService._();

  static bool canAccess(AppUser user, PermissionFeature feature) {
    if (!user.isValid) return false;

    if (feature == PermissionFeature.zodiac) {
      return true;
    }

    switch (user.levelUser) {
      case LevelUser.admin:
        return true;
      case LevelUser.supervisor:
        return feature != PermissionFeature.createAccount &&
            feature != PermissionFeature.viewAllProfiles;
      case LevelUser.stafCustomer:
        return {
          PermissionFeature.profile,
          PermissionFeature.quiz,
          PermissionFeature.calculator,
          PermissionFeature.discount,
          PermissionFeature.bilangan,
        }.contains(feature);
      case LevelUser.customer:
        return {
          PermissionFeature.profile,
          PermissionFeature.quiz,
          PermissionFeature.polling,
        }.contains(feature);
    }
  }

  static List<PermissionFeature> permissionsFor(AppUser user) {
    return PermissionFeature.values
        .where((feature) => canAccess(user, feature))
        .toList(growable: false);
  }
}
