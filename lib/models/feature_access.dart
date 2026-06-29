import 'permission.dart';

/// A storage-agnostic permission value used by local and future remote stores.
class FeatureAccess {
  final PermissionFeature feature;
  final bool allowed;

  const FeatureAccess({required this.feature, required this.allowed});

  FeatureAccess copyWith({bool? allowed}) {
    return FeatureAccess(feature: feature, allowed: allowed ?? this.allowed);
  }
}
