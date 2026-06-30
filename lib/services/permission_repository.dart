import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/level_user.dart';
import '../models/permission.dart';

abstract class PermissionRepository {
  Future<Map<PermissionFeature, bool>> getPermissionsForRole(LevelUser role);

  Future<Map<PermissionFeature, bool>> getPermissionsForUser(String userId);

  Future<void> updatePermissionForRole(
    LevelUser role,
    PermissionFeature feature,
    bool allowed,
  );

  Future<void> updatePermissionForUser(
    String userId,
    PermissionFeature feature,
    bool allowed,
  );
}

class SupabasePermissionRepository implements PermissionRepository {
  final SupabaseClient? _injectedClient;

  SupabasePermissionRepository({SupabaseClient? client})
    : _injectedClient = client;

  SupabaseClient get _client => _injectedClient ?? SupabaseConfig.client;

  @override
  Future<Map<PermissionFeature, bool>> getPermissionsForRole(
    LevelUser role,
  ) async {
    final rows = await _client
        .from('role_permissions')
        .select('feature_code, allowed')
        .eq('role_id', role.id);

    return _permissionsFromRows(rows);
  }

  @override
  Future<Map<PermissionFeature, bool>> getPermissionsForUser(
    String userId,
  ) async {
    final rows = await _client
        .from('user_permissions')
        .select('feature_code, allowed')
        .eq('user_id', userId);

    return _permissionsFromRows(rows);
  }

  @override
  Future<void> updatePermissionForRole(
    LevelUser role,
    PermissionFeature feature,
    bool allowed,
  ) async {
    await _client.from('role_permissions').upsert({
      'role_id': role.id,
      'feature_code': feature.databaseKey,
      'allowed': allowed,
    }, onConflict: 'role_id,feature_code');
  }

  @override
  Future<void> updatePermissionForUser(
    String userId,
    PermissionFeature feature,
    bool allowed,
  ) async {
    await _client.from('user_permissions').upsert({
      'user_id': userId,
      'feature_code': feature.databaseKey,
      'allowed': allowed,
    }, onConflict: 'user_id,feature_code');
  }

  Map<PermissionFeature, bool> _permissionsFromRows(
    List<Map<String, dynamic>> rows,
  ) {
    final result = <PermissionFeature, bool>{};
    for (final row in rows) {
      final featureCode = row['feature_code'];
      if (featureCode is! String) continue;

      final feature = PermissionFeatureLabel.fromDatabaseKey(featureCode);
      if (feature != null) result[feature] = row['allowed'] == true;
    }
    return result;
  }
}
