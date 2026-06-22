import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/permission.dart';
import '../widgets/app_components.dart';

class UnauthorizedPage extends StatelessWidget {
  final AppUser? user;
  final PermissionFeature? feature;

  const UnauthorizedPage({super.key, this.user, this.feature});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final featureLabel = feature?.label ?? 'fitur ini';
    final roleLabel = user?.levelUser.label ?? 'user';

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Unauthorized')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: CustomCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconBubble(
                    icon: Icons.lock_outline_rounded,
                    color: colors.error,
                    size: 72,
                    backgroundColor: colors.error.withValues(alpha: 0.12),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Akses Ditolak',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Role $roleLabel tidak memiliki izin untuk mengakses $featureLabel.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
