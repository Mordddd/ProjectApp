import '../models/app_user.dart';
import '../models/feature_access.dart';
import '../models/level_user.dart';
import '../models/permission.dart';
import 'permission_repository.dart';

class PermissionService {
  PermissionService._();

  static PermissionRepository _repository = LocalPermissionRepository();
  static final Map<LevelUser, Map<PermissionFeature, bool>> _saved = {};

  /// Loads persisted overrides. Call during session startup before rendering
  /// permission-aware UI.
  static Future<void> initialize({PermissionRepository? repository}) async {
    if (repository != null) _repository = repository;
    _saved.clear();
    for (final role in LevelUser.values) {
      _saved[role] = await _repository.getPermissionsForRole(role);
    }
  }

  static List<PermissionFeature> getAllFeatures() {
    return const [
      PermissionFeature.profile,
      PermissionFeature.quiz,
      PermissionFeature.multiQuiz,
      PermissionFeature.polling,
      PermissionFeature.calculator,
      PermissionFeature.maxMin,
      PermissionFeature.discount,
      PermissionFeature.bilangan,
      PermissionFeature.sorting,
      PermissionFeature.zodiac,
      PermissionFeature.createAccount,
      PermissionFeature.viewAllProfiles,
    ];
  }

  static List<FeatureAccess> getPermissionsForRole(LevelUser role) {
    return getAllFeatures()
        .map(
          (feature) => FeatureAccess(
            feature: feature,
            allowed: _effectivePermission(role, feature),
          ),
        )
        .toList(growable: false);
  }

  static Future<void> updatePermissionForRole(
    LevelUser role,
    PermissionFeature feature,
    bool allowed,
  ) async {
    if (feature == PermissionFeature.accessControl) return;
    await _repository.updatePermissionForRole(role, feature, allowed);
    (_saved[role] ??= {})[feature] = allowed;
  }

  static List<PermissionFeature> getPermissionsForUser(AppUser user) {
    if (!user.isValid) return const [];
    return getAllFeatures()
        .where((feature) => canAccess(user, feature))
        .toList(growable: false);
  }

  static bool canAccess(AppUser user, PermissionFeature feature) {
    if (!user.isValid) return false;
    if (feature == PermissionFeature.accessControl) {
      return user.levelUser.isAdmin;
    }
    return _effectivePermission(user.levelUser, feature);
  }

  /// Backwards-compatible alias used by existing callers.
  static List<PermissionFeature> permissionsFor(AppUser user) {
    return getPermissionsForUser(user);
  }

  static bool _effectivePermission(LevelUser role, PermissionFeature feature) {
    final custom = _saved[role]?[feature];
    return custom ?? _defaultPermissions(role).contains(feature);
  }

  static Set<PermissionFeature> _defaultPermissions(LevelUser role) {
    switch (role) {
      case LevelUser.admin:
        return getAllFeatures().toSet();
      case LevelUser.supervisor:
        return getAllFeatures()
            .where(
              (feature) =>
                  feature != PermissionFeature.createAccount &&
                  feature != PermissionFeature.viewAllProfiles,
            )
            .toSet();
      case LevelUser.stafCustomer:
        return const {
          PermissionFeature.profile,
          PermissionFeature.quiz,
          PermissionFeature.calculator,
          PermissionFeature.discount,
          PermissionFeature.bilangan,
          PermissionFeature.zodiac,
        };
      case LevelUser.customer:
        return const {
          PermissionFeature.profile,
          PermissionFeature.quiz,
          PermissionFeature.polling,
          PermissionFeature.zodiac,
        };
    }
  }
}
