import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/level_user.dart';
import '../models/permission.dart';
import '../services/auth_service.dart';
import '../services/permission_service.dart';
import '../widgets/app_components.dart';
import 'unauthorized_page.dart';

class CreateAccountPage extends StatefulWidget {
  final AppUser currentUser;

  const CreateAccountPage({super.key, required this.currentUser});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _divisionController = TextEditingController(text: 'General');

  LevelUser _selectedLevel = LevelUser.customer;
  bool _isSaving = false;
  List<AppUser> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _divisionController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final users = await _authService.getAllUsers();
    if (!mounted) return;
    setState(() => _users = users);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final result = await _authService.createAccount(
      username: _usernameController.text,
      password: _passwordController.text,
      namaLengkap: _fullNameController.text,
      levelUser: _selectedLevel,
      email: _emailController.text,
      noTelp: _phoneController.text,
      namaDivisi: _divisionController.text.trim().isEmpty
          ? 'General'
          : _divisionController.text.trim(),
      kodeDivisi: _divisionCode(),
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));

    if (!result.success) return;

    _usernameController.clear();
    _passwordController.clear();
    _fullNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _divisionController.text = 'General';
    setState(() => _selectedLevel = LevelUser.customer);
    await _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    if (!PermissionService.canAccess(
      widget.currentUser,
      PermissionFeature.createAccount,
    )) {
      return UnauthorizedPage(
        user: widget.currentUser,
        feature: PermissionFeature.createAccount,
      );
    }

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Create Account')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          CustomCard(
            color: AppPalette.navy,
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            child: Row(
              children: [
                IconBubble(
                  icon: Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Buat akun user baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          CustomCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: Icon(Icons.badge_rounded),
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Field wajib diisi';
                      }
                      if (value.trim().length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<LevelUser>(
                    initialValue: _selectedLevel,
                    decoration: const InputDecoration(
                      labelText: 'Level User',
                      prefixIcon: Icon(Icons.security_rounded),
                    ),
                    items: LevelUser.values.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(level.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedLevel = value);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'No. Telepon',
                      prefixIcon: Icon(Icons.phone_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _divisionController,
                    decoration: const InputDecoration(
                      labelText: 'Divisi',
                      prefixIcon: Icon(Icons.apartment_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_add_rounded),
                    label: Text(_isSaving ? 'Menyimpan...' : 'Buat Akun'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          SectionHeader(title: 'User Terdaftar'),
          const SizedBox(height: 10),
          ..._users.map(
            (user) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _UserTile(user: user),
            ),
          ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field wajib diisi';
    }
    return null;
  }

  String _divisionCode() {
    final normalized = _divisionController.text.trim().toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    if (normalized.isEmpty) return 'GEN';
    if (normalized.length <= 3) return normalized.padRight(3, 'X');
    return normalized.substring(0, 3);
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return CustomCard(
      padding: const EdgeInsets.all(14),
      shadows: const [],
      child: Row(
        children: [
          IconBubble(
            icon: user.levelUser.isAdmin
                ? Icons.admin_panel_settings_rounded
                : Icons.person_rounded,
            color: user.isValid ? AppPalette.navy : colors.error,
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.profile.namaLengkap,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${user.username} - ${user.levelUser.label} - ${user.statusLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
