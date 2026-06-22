import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/permission.dart';
import '../pages/unauthorized_page.dart';
import '../services/permission_service.dart';

class PermissionGuard extends StatelessWidget {
  final AppUser user;
  final PermissionFeature feature;
  final Widget child;
  final Widget? fallback;

  const PermissionGuard({
    super.key,
    required this.user,
    required this.feature,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (PermissionService.canAccess(user, feature)) {
      return child;
    }

    return fallback ?? UnauthorizedPage(user: user, feature: feature);
  }
}
