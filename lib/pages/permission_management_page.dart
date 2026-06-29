import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/feature_access.dart';
import '../models/level_user.dart';
import '../models/permission.dart';
import '../services/permission_service.dart';
import '../widgets/app_components.dart';
import 'unauthorized_page.dart';

class PermissionManagementPage extends StatefulWidget {
  final AppUser currentUser;

  const PermissionManagementPage({super.key, required this.currentUser});

  @override
  State<PermissionManagementPage> createState() =>
      _PermissionManagementPageState();
}

class _PermissionManagementPageState extends State<PermissionManagementPage> {
  LevelUser _selectedRole = LevelUser.admin;
  late Map<PermissionFeature, bool> _permissions;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedRole();
  }

  void _loadSelectedRole() {
    _permissions = {
      for (final access in PermissionService.getPermissionsForRole(
        _selectedRole,
      ))
        access.feature: access.allowed,
    };
  }

  void _selectRole(LevelUser? role) {
    if (role == null) return;
    setState(() {
      _selectedRole = role;
      _loadSelectedRole();
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      for (final entry in _permissions.entries) {
        await PermissionService.updatePermissionForRole(
          _selectedRole,
          entry.key,
          entry.value,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission ${_selectedRole.label} berhasil disimpan.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!PermissionService.canAccess(
      widget.currentUser,
      PermissionFeature.accessControl,
    )) {
      return UnauthorizedPage(
        user: widget.currentUser,
        feature: PermissionFeature.accessControl,
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Access Control')),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            CustomCard(
              color: const Color(0xFF082052),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              child: const Row(
                children: [
                  IconBubble(
                    icon: Icons.shield_rounded,
                    color: Colors.white,
                    backgroundColor: Color(0x24FFFFFF),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Atur akses fitur berdasarkan role',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<LevelUser>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                prefixIcon: Icon(Icons.groups_rounded),
              ),
              items: LevelUser.values
                  .map(
                    (role) =>
                        DropdownMenuItem(value: role, child: Text(role.label)),
                  )
                  .toList(growable: false),
              onChanged: _isSaving ? null : _selectRole,
            ),
            const SizedBox(height: 18),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < PermissionService.getAllFeatures().length;
                    index++
                  ) ...[
                    _PermissionSwitch(
                      access: FeatureAccess(
                        feature: PermissionService.getAllFeatures()[index],
                        allowed:
                            _permissions[PermissionService.getAllFeatures()[index]] ??
                            false,
                      ),
                      enabled: !_isSaving,
                      onChanged: (allowed) {
                        setState(() {
                          _permissions[PermissionService.getAllFeatures()[index]] =
                              allowed;
                        });
                      },
                    ),
                    if (index < PermissionService.getAllFeatures().length - 1)
                      Divider(
                        height: 1,
                        color: theme.colorScheme.outlineVariant,
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Permission'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionSwitch extends StatelessWidget {
  final FeatureAccess access;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _PermissionSwitch({
    required this.access,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: access.allowed,
      onChanged: enabled ? onChanged : null,
      title: Text(
        access.feature.label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      secondary: Icon(_iconFor(access.feature)),
      activeThumbColor: const Color(0xFF082052),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  IconData _iconFor(PermissionFeature feature) {
    switch (feature) {
      case PermissionFeature.profile:
        return Icons.person_rounded;
      case PermissionFeature.quiz:
        return Icons.quiz_rounded;
      case PermissionFeature.multiQuiz:
        return Icons.checklist_rounded;
      case PermissionFeature.polling:
        return Icons.poll_rounded;
      case PermissionFeature.calculator:
        return Icons.calculate_rounded;
      case PermissionFeature.maxMin:
        return Icons.maximize_rounded;
      case PermissionFeature.discount:
        return Icons.discount_rounded;
      case PermissionFeature.bilangan:
        return Icons.numbers_rounded;
      case PermissionFeature.sorting:
        return Icons.sort_rounded;
      case PermissionFeature.zodiac:
        return Icons.auto_awesome_rounded;
      case PermissionFeature.createAccount:
        return Icons.person_add_alt_1_rounded;
      case PermissionFeature.viewAllProfiles:
        return Icons.manage_accounts_rounded;
      case PermissionFeature.accessControl:
        return Icons.admin_panel_settings_rounded;
    }
  }
}
