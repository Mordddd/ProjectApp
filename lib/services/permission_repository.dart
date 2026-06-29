import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/level_user.dart';
import '../models/permission.dart';

abstract class PermissionRepository {
  Future<Map<PermissionFeature, bool>> getPermissionsForRole(LevelUser role);

  Future<void> updatePermissionForRole(
    LevelUser role,
    PermissionFeature feature,
    bool allowed,
  );
}

class LocalPermissionRepository implements PermissionRepository {
  static const _keyPrefix = 'role_permission';

  String _key(LevelUser role, PermissionFeature feature) {
    return '${_keyPrefix}_${role.code}_${feature.name}';
  }

  @override
  Future<Map<PermissionFeature, bool>> getPermissionsForRole(
    LevelUser role,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final result = <PermissionFeature, bool>{};

    for (final feature in PermissionFeature.values) {
      final key = _key(role, feature);
      if (prefs.containsKey(key)) {
        result[feature] = prefs.getBool(key) ?? false;
      }
    }
    return result;
  }

  @override
  Future<void> updatePermissionForRole(
    LevelUser role,
    PermissionFeature feature,
    bool allowed,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(role, feature), allowed);
  }
}

class SupabasePermissionRepository implements PermissionRepository {
  final SupabaseClient client;

  SupabasePermissionRepository(this.client);

  @override
  Future<Map<PermissionFeature, bool>> getPermissionsForRole(
    LevelUser role,
  ) async {
    final rows = await client
        .from('role_permissions')
        .select('feature_code, allowed')
        .eq('role_id', role.id);

    final result = <PermissionFeature, bool>{};
    for (final row in rows) {
      final feature = PermissionFeatureLabel.fromDatabaseKey(
        row['feature_code'] as String,
      );
      if (feature != null) result[feature] = row['allowed'] as bool;
    }
    return result;
  }

  @override
  Future<void> updatePermissionForRole(
    LevelUser role,
    PermissionFeature feature,
    bool allowed,
  ) async {
    await client.from('role_permissions').upsert({
      'role_id': role.id,
      'feature_code': feature.databaseKey,
      'allowed': allowed,
    });
  }
}
