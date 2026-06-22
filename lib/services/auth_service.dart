import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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

  Future<AuthResult> login(String username, String password) async {
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<AppUser?> getCurrentUser() async {
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
    return [..._dummyUsers, ...await _getLocalUsers()];
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
