import 'level_user.dart';
import 'user_profile.dart';

class AppUser {
  final String? authId;
  final int idUser;
  final String username;
  final String pass;
  final int idProfile;
  final int idLevelUser;
  final String idStatusValid;
  final UserProfile profile;
  final LevelUser levelUser;

  AppUser({
    this.authId,
    required this.idUser,
    required this.username,
    required this.pass,
    required this.idProfile,
    required this.idLevelUser,
    required this.idStatusValid,
    required this.profile,
    LevelUser? levelUser,
  }) : levelUser = levelUser ?? LevelUser.fromId(idLevelUser);

  bool get isValid => idStatusValid == '01';

  String get statusLabel {
    switch (idStatusValid) {
      case '01':
        return 'valid';
      case '02':
        return 'no valid';
      case '03':
        return 'keluar';
      default:
        return 'unknown';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'auth_id': authId,
      'id_user': idUser,
      'username': username,
      'pass': pass,
      'id_profile': idProfile,
      'id_level_user': idLevelUser,
      'id_status_valid': idStatusValid,
      'profile': profile.toJson(),
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final idLevelUser = json['id_level_user'] as int? ?? 4;
    final profileJson = json['profile'];
    return AppUser(
      authId: json['auth_id'] as String?,
      idUser: json['id_user'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      pass: json['pass'] as String? ?? '',
      idProfile: json['id_profile'] as int? ?? 0,
      idLevelUser: idLevelUser,
      idStatusValid: json['id_status_valid'] as String? ?? '02',
      profile: profileJson is Map<String, dynamic>
          ? UserProfile.fromJson(profileJson)
          : UserProfile.empty(),
      levelUser: LevelUser.fromId(idLevelUser),
    );
  }

  AppUser copyWith({
    String? authId,
    int? idUser,
    String? username,
    String? pass,
    int? idProfile,
    int? idLevelUser,
    String? idStatusValid,
    UserProfile? profile,
    LevelUser? levelUser,
  }) {
    final nextLevelId = idLevelUser ?? this.idLevelUser;
    return AppUser(
      authId: authId ?? this.authId,
      idUser: idUser ?? this.idUser,
      username: username ?? this.username,
      pass: pass ?? this.pass,
      idProfile: idProfile ?? this.idProfile,
      idLevelUser: nextLevelId,
      idStatusValid: idStatusValid ?? this.idStatusValid,
      profile: profile ?? this.profile,
      levelUser: levelUser ?? LevelUser.fromId(nextLevelId),
    );
  }
}
