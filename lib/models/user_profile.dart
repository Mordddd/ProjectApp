class UserProfile {
  final String id;
  final String name;
  final String bio;
  final String? photoPath;
  final String? videoUrl;
  final String hobby;
  final String joinDate;
  final bool isCurrentUser;
  final int idProfile;
  final String nama;
  final String namaLengkap;
  final String nik;
  final String alamat;
  final String noTelp;
  final int idDivisi;
  final String email;
  final String pendidikan;
  final int idHobyImage;
  final int idHobyMovie;
  final String kodeDivisi;
  final String namaDivisi;
  final String namaImage;
  final String namafileImage;
  final String namaMovie;
  final String namafileMovie;

  UserProfile({
    required this.id,
    required this.name,
    required this.bio,
    this.photoPath,
    this.videoUrl,
    required this.hobby,
    required this.joinDate,
    this.isCurrentUser = false,
    int? idProfile,
    String? nama,
    String? namaLengkap,
    this.nik = '',
    this.alamat = '',
    this.noTelp = '',
    this.idDivisi = 0,
    this.email = '',
    this.pendidikan = '',
    this.idHobyImage = 0,
    this.idHobyMovie = 0,
    this.kodeDivisi = '',
    this.namaDivisi = '',
    this.namaImage = '',
    this.namafileImage = '',
    this.namaMovie = '',
    this.namafileMovie = '',
  }) : idProfile = idProfile ?? int.tryParse(id) ?? 0,
       nama = nama ?? name,
       namaLengkap = namaLengkap ?? name;

  factory UserProfile.empty() {
    return UserProfile(id: '0', name: '', bio: '', hobby: '', joinDate: '');
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '${json['id_profile'] ?? 0}',
      name: json['name'] as String? ?? json['nama_lengkap'] as String? ?? '',
      bio: json['bio'] as String? ?? json['alamat'] as String? ?? '',
      photoPath: json['photo_path'] as String?,
      videoUrl: json['video_url'] as String?,
      hobby: json['hobby'] as String? ?? '',
      joinDate: json['join_date'] as String? ?? '',
      isCurrentUser: json['is_current_user'] as bool? ?? false,
      idProfile: json['id_profile'] as int?,
      nama: json['nama'] as String?,
      namaLengkap: json['nama_lengkap'] as String?,
      nik: json['nik'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      noTelp: json['no_telp'] as String? ?? '',
      idDivisi: json['id_divisi'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      pendidikan: json['pendidikan'] as String? ?? '',
      idHobyImage: json['id_hoby_image'] as int? ?? 0,
      idHobyMovie: json['id_hoby_movie'] as int? ?? 0,
      kodeDivisi: json['kode_divisi'] as String? ?? '',
      namaDivisi: json['nama_divisi'] as String? ?? '',
      namaImage: json['nama_image'] as String? ?? '',
      namafileImage: json['namafile_image'] as String? ?? '',
      namaMovie: json['nama_movie'] as String? ?? '',
      namafileMovie: json['namafile_movie'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'photo_path': photoPath,
      'video_url': videoUrl,
      'hobby': hobby,
      'join_date': joinDate,
      'is_current_user': isCurrentUser,
      'id_profile': idProfile,
      'nama': nama,
      'nama_lengkap': namaLengkap,
      'nik': nik,
      'alamat': alamat,
      'no_telp': noTelp,
      'id_divisi': idDivisi,
      'email': email,
      'pendidikan': pendidikan,
      'id_hoby_image': idHobyImage,
      'id_hoby_movie': idHobyMovie,
      'kode_divisi': kodeDivisi,
      'nama_divisi': namaDivisi,
      'nama_image': namaImage,
      'namafile_image': namafileImage,
      'nama_movie': namaMovie,
      'namafile_movie': namafileMovie,
    };
  }

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
        idProfile: 1,
        nama: 'Anya',
        namaLengkap: 'Anya Rahman',
        nik: '317100000001',
        alamat: 'Jakarta',
        noTelp: '081200000001',
        idDivisi: 3,
        email: 'anya@example.com',
        pendidikan: 'S1',
        idHobyImage: 1,
        idHobyMovie: 1,
        kodeDivisi: 'CST',
        namaDivisi: 'Customer Service',
        namaImage: 'Fotografi',
        namafileImage: 'fotografi.png',
        namaMovie: 'Teknologi',
        namafileMovie: 'teknologi.mp4',
      ),
      UserProfile(
        id: '2',
        name: 'Budi Santoso',
        bio:
            'Mobile app developer dengan pengalaman 5 tahun. Spesialisasi Android dan Flutter. Suka traveling dan eksplorasi kuliner.',
        hobby: 'Traveling, gaming, dan menulis blog',
        joinDate: 'Maret 2023',
        isCurrentUser: false,
        idProfile: 2,
        nama: 'Budi',
        namaLengkap: 'Budi Santoso',
        nik: '317100000002',
        alamat: 'Bandung',
        noTelp: '081200000002',
        idDivisi: 1,
        email: 'budi@example.com',
        pendidikan: 'S1',
        idHobyImage: 2,
        idHobyMovie: 2,
        kodeDivisi: 'ADM',
        namaDivisi: 'Administrasi',
        namaImage: 'Traveling',
        namafileImage: 'traveling.png',
        namaMovie: 'Kuliner',
        namafileMovie: 'kuliner.mp4',
      ),
      UserProfile(
        id: '3',
        name: 'Siti Nurhayati',
        bio:
            'UI/UX Designer yang juga belajar programming. Percaya bahwa design yang baik harus fungsional dan indah.',
        hobby: 'Design, menggambar, yoga, dan membaca',
        joinDate: 'Juli 2024',
        isCurrentUser: false,
        idProfile: 3,
        nama: 'Siti',
        namaLengkap: 'Siti Nurhayati',
        nik: '317100000003',
        alamat: 'Yogyakarta',
        noTelp: '081200000003',
        idDivisi: 2,
        email: 'siti@example.com',
        pendidikan: 'S1',
        idHobyImage: 3,
        idHobyMovie: 3,
        kodeDivisi: 'SPV',
        namaDivisi: 'Supervisi',
        namaImage: 'Desain',
        namafileImage: 'desain.png',
        namaMovie: 'Dokumenter',
        namafileMovie: 'dokumenter.mp4',
      ),
      UserProfile(
        id: '4',
        name: 'Doni Wijaya',
        bio:
            'Backend developer dan tech enthusiast. Gemar berbagi ilmu melalui komunitas. Sedang belajar machine learning.',
        hobby: 'Coding, research, badminton, dan musik',
        joinDate: 'September 2023',
        isCurrentUser: false,
        idProfile: 4,
        nama: 'Doni',
        namaLengkap: 'Doni Wijaya',
        nik: '317100000004',
        alamat: 'Surabaya',
        noTelp: '081200000004',
        idDivisi: 4,
        email: 'doni@example.com',
        pendidikan: 'S1',
        idHobyImage: 4,
        idHobyMovie: 4,
        kodeDivisi: 'CUS',
        namaDivisi: 'Customer',
        namaImage: 'Research',
        namafileImage: 'research.png',
        namaMovie: 'Musik',
        namafileMovie: 'musik.mp4',
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
    int? idProfile,
    String? nama,
    String? namaLengkap,
    String? nik,
    String? alamat,
    String? noTelp,
    int? idDivisi,
    String? email,
    String? pendidikan,
    int? idHobyImage,
    int? idHobyMovie,
    String? kodeDivisi,
    String? namaDivisi,
    String? namaImage,
    String? namafileImage,
    String? namaMovie,
    String? namafileMovie,
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
      idProfile: idProfile ?? this.idProfile,
      nama: nama ?? this.nama,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      nik: nik ?? this.nik,
      alamat: alamat ?? this.alamat,
      noTelp: noTelp ?? this.noTelp,
      idDivisi: idDivisi ?? this.idDivisi,
      email: email ?? this.email,
      pendidikan: pendidikan ?? this.pendidikan,
      idHobyImage: idHobyImage ?? this.idHobyImage,
      idHobyMovie: idHobyMovie ?? this.idHobyMovie,
      kodeDivisi: kodeDivisi ?? this.kodeDivisi,
      namaDivisi: namaDivisi ?? this.namaDivisi,
      namaImage: namaImage ?? this.namaImage,
      namafileImage: namafileImage ?? this.namafileImage,
      namaMovie: namaMovie ?? this.namaMovie,
      namafileMovie: namafileMovie ?? this.namafileMovie,
    );
  }
}
