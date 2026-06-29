import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/app_user.dart';
import '../models/level_user.dart';
import '../models/user_profile.dart';

class AuthResult {
  final bool success;
  final AppUser? user;
  final String message;

  const AuthResult({required this.success, required this.message, this.user});

  factory AuthResult.ok(AppUser user, String message) {
    return AuthResult(success: true, user: user, message: message);
  }

  factory AuthResult.fail(String message) {
    return AuthResult(success: false, message: message);
  }
}

class AuthService {
  static const _sessionKey = 'auth_current_username';
  static const _localUsersKey = 'auth_local_users';

  static bool get usesSupabase => SupabaseConfig.isConfigured;

  Future<AuthResult> login(String username, String password) async {
    if (usesSupabase) return _loginWithSupabase(username, password);

    final normalizedUsername = username.trim();
    final user = await _findUser(normalizedUsername);

    if (user == null || user.pass != password) {
      return AuthResult.fail('Username atau password salah.');
    }

    if (!user.isValid) {
      return AuthResult.fail(
        'Akun "${user.username}" berstatus ${user.statusLabel} dan tidak boleh masuk aplikasi.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, user.username);

    return AuthResult.ok(user, 'Login berhasil.');
  }

  Future<void> logout() async {
    if (usesSupabase) {
      await SupabaseConfig.client.auth.signOut();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<AppUser?> getCurrentUser() async {
    if (usesSupabase) return _getSupabaseCurrentUser();

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_sessionKey);
    if (username == null || username.isEmpty) return null;

    final user = await _findUser(username);
    if (user == null || !user.isValid) {
      await logout();
      return null;
    }

    return user;
  }

  Future<bool> isLoggedIn() async {
    return await getCurrentUser() != null;
  }

  Future<AuthResult> createAccount({
    required String username,
    required String password,
    required String namaLengkap,
    required LevelUser levelUser,
    String nama = '',
    String nik = '',
    String alamat = '',
    String noTelp = '',
    String email = '',
    String pendidikan = '',
    int idDivisi = 1,
    String kodeDivisi = 'GEN',
    String namaDivisi = 'General',
  }) async {
    if (usesSupabase) {
      return _createSupabaseAccount(
        username: username,
        password: password,
        namaLengkap: namaLengkap,
        levelUser: levelUser,
        nama: nama,
        nik: nik,
        alamat: alamat,
        noTelp: noTelp,
        email: email,
        pendidikan: pendidikan,
        kodeDivisi: kodeDivisi,
        namaDivisi: namaDivisi,
      );
    }

    final normalizedUsername = username.trim();
    final normalizedPassword = password.trim();
    final normalizedName = namaLengkap.trim();

    if (normalizedUsername.isEmpty ||
        normalizedPassword.isEmpty ||
        normalizedName.isEmpty) {
      return AuthResult.fail(
        'Username, password, dan nama lengkap wajib diisi.',
      );
    }

    final existing = await _findUser(normalizedUsername);
    if (existing != null) {
      return AuthResult.fail('Username sudah digunakan.');
    }

    final allUsers = await getAllUsers();
    final nextUserId = _nextId(allUsers.map((user) => user.idUser));
    final nextProfileId = _nextId(allUsers.map((user) => user.idProfile));
    final displayName = nama.trim().isNotEmpty ? nama.trim() : normalizedName;

    final profile = UserProfile(
      id: '$nextProfileId',
      name: normalizedName,
      bio: alamat.trim().isEmpty
          ? 'Profile dibuat oleh admin melalui simulasi SSO.'
          : alamat.trim(),
      hobby: 'Belum diisi',
      joinDate: 'Juni 2026',
      idProfile: nextProfileId,
      nama: displayName,
      namaLengkap: normalizedName,
      nik: nik.trim(),
      alamat: alamat.trim(),
      noTelp: noTelp.trim(),
      idDivisi: idDivisi,
      email: email.trim(),
      pendidikan: pendidikan.trim(),
      kodeDivisi: kodeDivisi.trim(),
      namaDivisi: namaDivisi.trim(),
    );

    final user = AppUser(
      idUser: nextUserId,
      username: normalizedUsername,
      pass: normalizedPassword,
      idProfile: nextProfileId,
      idLevelUser: levelUser.id,
      idStatusValid: '01',
      profile: profile,
      levelUser: levelUser,
    );

    final localUsers = await _getLocalUsers();
    await _saveLocalUsers([...localUsers, user]);

    return AuthResult.ok(user, 'Akun berhasil dibuat.');
  }

  Future<List<AppUser>> getAllUsers() async {
    if (usesSupabase) return _getSupabaseUsers();
    return [..._dummyUsers, ...await _getLocalUsers()];
  }

  Future<void> updateProfile(UserProfile profile) async {
    if (!usesSupabase) return;
    await SupabaseConfig.client
        .from('profiles')
        .update({
          'full_name': profile.name.trim(),
          'display_name': profile.name.trim(),
          'bio': profile.bio.trim(),
          'hobby': profile.hobby.trim(),
        })
        .eq('user_id', profile.id);
  }

  Future<AuthResult> _loginWithSupabase(
    String username,
    String password,
  ) async {
    final normalized = username.trim().toLowerCase();
    if (normalized.isEmpty || password.isEmpty) {
      return AuthResult.fail('Username dan password wajib diisi.');
    }

    try {
      final email = normalized.contains('@')
          ? normalized
          : '$normalized@learninghub.local';
      await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = await _fetchSupabaseUser();
      if (user == null) {
        return AuthResult.fail('Profil akun tidak ditemukan.');
      }
      if (!user.isValid) {
        await SupabaseConfig.client.auth.signOut();
        return AuthResult.fail(
          'Akun "${user.username}" berstatus ${user.statusLabel} dan tidak boleh masuk aplikasi.',
        );
      }
      return AuthResult.ok(user, 'Login berhasil.');
    } on AuthException catch (error) {
      return AuthResult.fail(_friendlyAuthError(error.message));
    } catch (_) {
      return AuthResult.fail(
        'Tidak dapat terhubung ke server. Periksa koneksi dan konfigurasi Supabase.',
      );
    }
  }

  Future<AppUser?> _getSupabaseCurrentUser() async {
    final user = await _fetchSupabaseUser();
    if (user != null && !user.isValid) {
      await SupabaseConfig.client.auth.signOut();
      return null;
    }
    return user;
  }

  Future<AppUser?> _fetchSupabaseUser() async {
    final authUser = SupabaseConfig.client.auth.currentUser;
    if (authUser == null) return null;

    final row = await SupabaseConfig.client
        .from('profiles')
        .select('*, roles!inner(id, code), divisions(code, name)')
        .eq('user_id', authUser.id)
        .single();
    return _appUserFromSupabase(row);
  }

  Future<List<AppUser>> _getSupabaseUsers() async {
    final rows = await SupabaseConfig.client
        .from('profiles')
        .select('*, roles!inner(id, code), divisions(code, name)')
        .order('created_at');
    return rows.map(_appUserFromSupabase).toList(growable: false);
  }

  Future<AuthResult> _createSupabaseAccount({
    required String username,
    required String password,
    required String namaLengkap,
    required LevelUser levelUser,
    required String nama,
    required String nik,
    required String alamat,
    required String noTelp,
    required String email,
    required String pendidikan,
    required String kodeDivisi,
    required String namaDivisi,
  }) async {
    final normalizedUsername = username.trim().toLowerCase();
    if (normalizedUsername.isEmpty ||
        password.length < 6 ||
        namaLengkap.trim().isEmpty) {
      return AuthResult.fail(
        'Username, password minimal 6 karakter, dan nama lengkap wajib diisi.',
      );
    }
    if (!RegExp(r'^[a-z0-9._-]+$').hasMatch(normalizedUsername)) {
      return AuthResult.fail(
        'Username hanya boleh berisi huruf kecil, angka, titik, garis bawah, atau tanda hubung.',
      );
    }

    try {
      final response = await SupabaseConfig.client.functions.invoke(
        'admin-create-user',
        body: {
          'username': normalizedUsername,
          'password': password,
          'full_name': namaLengkap.trim(),
          'display_name': nama.trim(),
          'role_id': levelUser.id,
          'nik': nik.trim(),
          'address': alamat.trim(),
          'phone': noTelp.trim(),
          'contact_email': email.trim(),
          'education': pendidikan.trim(),
          'division_code': kodeDivisi.trim(),
          'division_name': namaDivisi.trim(),
        },
      );
      final data = response.data;
      if (response.status < 200 || response.status >= 300) {
        final message = data is Map ? data['error']?.toString() : null;
        return AuthResult.fail(message ?? 'Gagal membuat akun.');
      }
      final created = data is Map ? data['profile'] : null;
      if (created is! Map) {
        return AuthResult.fail(
          'Server mengembalikan data akun yang tidak valid.',
        );
      }
      final user = _appUserFromSupabase(Map<String, dynamic>.from(created));
      return AuthResult.ok(user, 'Akun berhasil dibuat.');
    } catch (error) {
      return AuthResult.fail(_friendlyRemoteError(error));
    }
  }

  AppUser _appUserFromSupabase(Map<String, dynamic> row) {
    final roleData = row['roles'];
    final divisionData = row['divisions'];
    final roleMap = roleData is Map ? roleData : const <String, dynamic>{};
    final divisionMap = divisionData is Map
        ? divisionData
        : const <String, dynamic>{};
    final roleId =
        (row['role_id'] as num?)?.toInt() ??
        (roleMap['id'] as num?)?.toInt() ??
        LevelUser.customer.id;
    final legacyId = (row['legacy_id'] as num?)?.toInt() ?? 0;
    final createdAt = row['created_at']?.toString() ?? '';
    final fullName = row['full_name']?.toString() ?? '';
    final displayName = row['display_name']?.toString();
    final status = row['account_status']?.toString() ?? 'blocked';

    final profile = UserProfile(
      id: row['user_id']?.toString() ?? '$legacyId',
      name: fullName,
      bio: row['bio']?.toString() ?? '',
      photoPath: row['avatar_path']?.toString(),
      videoUrl: row['video_path']?.toString(),
      hobby: row['hobby']?.toString() ?? '',
      joinDate: createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt,
      idProfile: legacyId,
      nama: (displayName == null || displayName.isEmpty)
          ? fullName
          : displayName,
      namaLengkap: fullName,
      nik: row['nik']?.toString() ?? '',
      alamat: row['address']?.toString() ?? '',
      noTelp: row['phone']?.toString() ?? '',
      idDivisi: (row['division_id'] as num?)?.toInt() ?? 0,
      email: row['contact_email']?.toString() ?? '',
      pendidikan: row['education']?.toString() ?? '',
      kodeDivisi: divisionMap['code']?.toString() ?? '',
      namaDivisi: divisionMap['name']?.toString() ?? '',
      namafileImage: row['avatar_path']?.toString() ?? '',
      namafileMovie: row['video_path']?.toString() ?? '',
    );

    return AppUser(
      authId: row['user_id']?.toString(),
      idUser: legacyId,
      username: row['username']?.toString() ?? '',
      pass: '',
      idProfile: legacyId,
      idLevelUser: roleId,
      idStatusValid: switch (status) {
        'active' => '01',
        'departed' => '03',
        _ => '02',
      },
      profile: profile,
      levelUser: LevelUser.fromId(roleId),
    );
  }

  String _friendlyAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Username atau password salah.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Akun belum dikonfirmasi.';
    }
    return message;
  }

  String _friendlyRemoteError(Object error) {
    final message = error.toString();
    if (message.contains('already registered') ||
        message.contains('duplicate key')) {
      return 'Username sudah digunakan.';
    }
    return 'Gagal membuat akun: $message';
  }

  Future<AppUser?> _findUser(String username) async {
    final normalizedUsername = username.trim().toLowerCase();
    final users = await getAllUsers();

    for (final user in users) {
      if (user.username.toLowerCase() == normalizedUsername) {
        return user;
      }
    }

    return null;
  }

  Future<List<AppUser>> _getLocalUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_localUsersKey);
    if (encoded == null || encoded.isEmpty) return [];

    final decoded = jsonDecode(encoded);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(AppUser.fromJson)
        .toList(growable: false);
  }

  Future<void> _saveLocalUsers(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(users.map((user) => user.toJson()).toList());
    await prefs.setString(_localUsersKey, encoded);
  }

  int _nextId(Iterable<int> ids) {
    var biggest = 0;
    for (final id in ids) {
      if (id > biggest) biggest = id;
    }
    return biggest + 1;
  }

  static List<AppUser> get _dummyUsers {
    return [
      _buildDummyUser(
        idUser: 1,
        username: 'admin',
        pass: 'admin123',
        levelUser: LevelUser.admin,
        idStatusValid: '01',
        namaLengkap: 'Administrator Learning Hub',
        nama: 'Admin',
        email: 'admin@learninghub.local',
        idDivisi: 1,
        kodeDivisi: 'ADM',
        namaDivisi: 'Administrasi',
      ),
      _buildDummyUser(
        idUser: 2,
        username: 'supervisor',
        pass: 'super123',
        levelUser: LevelUser.supervisor,
        idStatusValid: '01',
        namaLengkap: 'Supervisor Customer Service',
        nama: 'Supervisor',
        email: 'supervisor@learninghub.local',
        idDivisi: 2,
        kodeDivisi: 'SPV',
        namaDivisi: 'Supervisi',
      ),
      _buildDummyUser(
        idUser: 3,
        username: 'staf',
        pass: 'staf123',
        levelUser: LevelUser.stafCustomer,
        idStatusValid: '01',
        namaLengkap: 'Staf Customer',
        nama: 'Staf',
        email: 'staf@learninghub.local',
        idDivisi: 3,
        kodeDivisi: 'CST',
        namaDivisi: 'Customer Service',
      ),
      _buildDummyUser(
        idUser: 4,
        username: 'customer',
        pass: 'customer123',
        levelUser: LevelUser.customer,
        idStatusValid: '01',
        namaLengkap: 'Customer Learning Hub',
        nama: 'Customer',
        email: 'customer@learninghub.local',
        idDivisi: 4,
        kodeDivisi: 'CUS',
        namaDivisi: 'Customer',
      ),
      _buildDummyUser(
        idUser: 5,
        username: 'blocked',
        pass: 'blocked123',
        levelUser: LevelUser.customer,
        idStatusValid: '02',
        namaLengkap: 'Blocked Customer',
        nama: 'Blocked',
        email: 'blocked@learninghub.local',
        idDivisi: 4,
        kodeDivisi: 'CUS',
        namaDivisi: 'Customer',
      ),
    ];
  }

  static AppUser _buildDummyUser({
    required int idUser,
    required String username,
    required String pass,
    required LevelUser levelUser,
    required String idStatusValid,
    required String namaLengkap,
    required String nama,
    required String email,
    required int idDivisi,
    required String kodeDivisi,
    required String namaDivisi,
  }) {
    final profile = UserProfile(
      id: '$idUser',
      name: namaLengkap,
      bio: 'Akun demo $namaLengkap untuk simulasi SSO lokal.',
      hobby: 'Belajar, teknologi, dan eksplorasi aplikasi',
      joinDate: 'Juni 2026',
      idProfile: idUser,
      nama: nama,
      namaLengkap: namaLengkap,
      nik: 'NIK$idUser',
      alamat: 'Alamat demo $namaDivisi',
      noTelp: '08120000000$idUser',
      idDivisi: idDivisi,
      email: email,
      pendidikan: 'S1',
      idHobyImage: idUser,
      idHobyMovie: idUser,
      namaImage: 'Hobi Image $idUser',
      namafileImage: 'hoby_image_$idUser.png',
      namaMovie: 'Hobi Movie $idUser',
      namafileMovie: 'hoby_movie_$idUser.mp4',
      kodeDivisi: kodeDivisi,
      namaDivisi: namaDivisi,
    );

    return AppUser(
      idUser: idUser,
      username: username,
      pass: pass,
      idProfile: idUser,
      idLevelUser: levelUser.id,
      idStatusValid: idStatusValid,
      profile: profile,
      levelUser: levelUser,
    );
  }
}
