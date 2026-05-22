class UserProfile {
  final String id;
  final String name;
  final String bio;
  final String? photoPath;
  final String? videoUrl;
  final String hobby;
  final String joinDate;
  final bool isCurrentUser;

  const UserProfile({
    required this.id,
    required this.name,
    required this.bio,
    this.photoPath,
    this.videoUrl,
    required this.hobby,
    required this.joinDate,
    this.isCurrentUser = false,
  });

  // Mock data untuk 4 profil
  static List<UserProfile> getMockProfiles() {
    return [
      UserProfile(
        id: '1',
        name: 'Anya Rahman',
        bio:
            'Seorang developer muda yang passionate tentang teknologi Flutter. Suka belajar hal baru setiap hari.',
        hobby: 'Coding, bermain game, dan fotografi',
        joinDate: 'Januari 2024',
        isCurrentUser: true,
      ),
      UserProfile(
        id: '2',
        name: 'Budi Santoso',
        bio:
            'Mobile app developer dengan pengalaman 5 tahun. Spesialisasi Android dan Flutter. Suka traveling dan eksplorasi kuliner.',
        hobby: 'Traveling, gaming, dan menulis blog',
        joinDate: 'Maret 2023',
        isCurrentUser: false,
      ),
      UserProfile(
        id: '3',
        name: 'Siti Nurhayati',
        bio:
            'UI/UX Designer yang juga belajar programming. Percaya bahwa design yang baik harus fungsional dan indah.',
        hobby: 'Design, menggambar, yoga, dan membaca',
        joinDate: 'Juli 2024',
        isCurrentUser: false,
      ),
      UserProfile(
        id: '4',
        name: 'Doni Wijaya',
        bio:
            'Backend developer dan tech enthusiast. Gemar berbagi ilmu melalui komunitas. Sedang belajar machine learning.',
        hobby: 'Coding, research, badminton, dan musik',
        joinDate: 'September 2023',
        isCurrentUser: false,
      ),
    ];
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? bio,
    String? photoPath,
    String? videoUrl,
    String? hobby,
    String? joinDate,
    bool? isCurrentUser,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      photoPath: photoPath ?? this.photoPath,
      videoUrl: videoUrl ?? this.videoUrl,
      hobby: hobby ?? this.hobby,
      joinDate: joinDate ?? this.joinDate,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}
