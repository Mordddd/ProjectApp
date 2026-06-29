import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../models/app_user.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../widgets/app_components.dart';

class ProfilePage extends StatefulWidget {
  final AppUser? currentUser;
  final bool canViewAllProfiles;

  const ProfilePage({
    super.key,
    this.currentUser,
    this.canViewAllProfiles = true,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedTab = 0; // 0: My Profile, 1: Browse Profiles

  // Current User Data
  late UserProfile _currentUser;
  File? imageFile;
  Map<String, File?> profileVideos = {};
  final picker = ImagePicker();
  final _authService = AuthService();

  // Browse profiles
  late List<UserProfile> _allProfiles;
  int _currentProfileIndex = 1; // Start from index 1 (other users)

  @override
  void initState() {
    super.initState();
    _initializeProfiles();
    loadData();
    _loadProfileVideos();
    if (AuthService.usesSupabase) _loadRemoteProfiles();
  }

  void _initializeProfiles() {
    _allProfiles = UserProfile.getMockProfiles();
    final loggedInProfile = widget.currentUser?.profile;
    if (loggedInProfile != null) {
      _allProfiles[0] = _allProfiles[0].copyWith(
        id: loggedInProfile.id,
        name: loggedInProfile.namaLengkap.isEmpty
            ? loggedInProfile.name
            : loggedInProfile.namaLengkap,
        bio: loggedInProfile.bio.isEmpty
            ? 'Belum ada deskripsi profil.'
            : loggedInProfile.bio,
        hobby: loggedInProfile.hobby.isEmpty
            ? 'Belum diisi'
            : loggedInProfile.hobby,
        joinDate: loggedInProfile.joinDate.isEmpty
            ? _allProfiles[0].joinDate
            : loggedInProfile.joinDate,
        isCurrentUser: true,
        idProfile: loggedInProfile.idProfile,
        nama: loggedInProfile.nama,
        namaLengkap: loggedInProfile.namaLengkap,
        nik: loggedInProfile.nik,
        alamat: loggedInProfile.alamat,
        noTelp: loggedInProfile.noTelp,
        idDivisi: loggedInProfile.idDivisi,
        email: loggedInProfile.email,
        pendidikan: loggedInProfile.pendidikan,
        idHobyImage: loggedInProfile.idHobyImage,
        idHobyMovie: loggedInProfile.idHobyMovie,
        kodeDivisi: loggedInProfile.kodeDivisi,
        namaDivisi: loggedInProfile.namaDivisi,
        namaImage: loggedInProfile.namaImage,
        namafileImage: loggedInProfile.namafileImage,
        namaMovie: loggedInProfile.namaMovie,
        namafileMovie: loggedInProfile.namafileMovie,
      );
    }
    _currentUser = _allProfiles[0]; // First profile is current user
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      if (!AuthService.usesSupabase) {
        _currentUser = _currentUser.copyWith(
          name:
              prefs.getString('${_currentProfilePrefix}_name') ??
              _currentUser.name,
          bio:
              prefs.getString('${_currentProfilePrefix}_bio') ??
              _currentUser.bio,
          hobby:
              prefs.getString('${_currentProfilePrefix}_hobby') ??
              _currentUser.hobby,
        );
      }

      String? imagePath = prefs.getString('${_currentProfilePrefix}_image');
      if (imagePath != null) imageFile = File(imagePath);
    });

    await _loadOtherProfilesData();
  }

  Future<void> _loadOtherProfilesData() async {
    if (AuthService.usesSupabase) return;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      for (int i = 1; i < _allProfiles.length; i++) {
        final profile = _allProfiles[i];
        final name = prefs.getString('profile_${profile.id}_name');
        final bio = prefs.getString('profile_${profile.id}_bio');
        final hobby = prefs.getString('profile_${profile.id}_hobby');

        if (name != null || bio != null || hobby != null) {
          _allProfiles[i] = profile.copyWith(
            name: name ?? profile.name,
            bio: bio ?? profile.bio,
            hobby: hobby ?? profile.hobby,
          );
        }
      }
    });
  }

  Future<void> _loadProfileVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final videos = <String, File?>{};

    for (final profile in _allProfiles) {
      final videoPath = prefs.getString('profile_video_${profile.id}');
      final videoFile = videoPath != null ? File(videoPath) : null;
      if (videoFile != null && videoFile.existsSync()) {
        videos[profile.id] = videoFile;
      } else {
        videos[profile.id] = null;
      }
    }

    if (!mounted) return;
    setState(() {
      profileVideos = videos;
    });
  }

  Future<void> saveData() async {
    try {
      if (AuthService.usesSupabase) {
        await _authService.updateProfile(_currentUser);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan profil ke server.')),
        );
      }
      return;
    }
    final prefs = await SharedPreferences.getInstance();

    if (!AuthService.usesSupabase) {
      await prefs.setString('${_currentProfilePrefix}_name', _currentUser.name);
      await prefs.setString('${_currentProfilePrefix}_bio', _currentUser.bio);
      await prefs.setString(
        '${_currentProfilePrefix}_hobby',
        _currentUser.hobby,
      );
    }

    if (imageFile != null) {
      await prefs.setString('${_currentProfilePrefix}_image', imageFile!.path);
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profil tersimpan!")));
    }
  }

  Future<void> _saveProfileData(
    int profileIndex,
    UserProfile updatedProfile,
  ) async {
    try {
      if (AuthService.usesSupabase) {
        await _authService.updateProfile(updatedProfile);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan profil ke server.')),
        );
      }
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final profileId = updatedProfile.id;

    if (!AuthService.usesSupabase) {
      await prefs.setString('profile_${profileId}_name', updatedProfile.name);
      await prefs.setString('profile_${profileId}_bio', updatedProfile.bio);
      await prefs.setString('profile_${profileId}_hobby', updatedProfile.hobby);
    }

    if (!mounted) return;
    setState(() {
      _allProfiles[profileIndex] = updatedProfile;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profil tersimpan!")));
    }
  }

  Future<void> _saveProfileVideo(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final videoFile = profileVideos[profileId];

    if (videoFile != null) {
      await prefs.setString('profile_video_$profileId', videoFile.path);
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Video tersimpan!")));
    }
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null && mounted) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<void> pickVideo() async {
    final picked = await picker.pickVideo(source: ImageSource.gallery);

    if (picked != null && mounted) {
      setState(() {
        profileVideos[_currentUser.id] = File(picked.path);
      });
      await _saveProfileVideo(_currentUser.id);
    }
  }

  Future<void> pickVideoForProfile(String profileId) async {
    final picked = await picker.pickVideo(source: ImageSource.gallery);

    if (picked != null && mounted) {
      setState(() {
        profileVideos[profileId] = File(picked.path);
      });
      await _saveProfileVideo(profileId);
    }
  }

  String get _currentProfilePrefix => 'profile_${_currentUser.id}';

  Future<void> _loadRemoteProfiles() async {
    try {
      final users = await _authService.getAllUsers();
      if (!mounted || users.isEmpty) return;
      final currentId = widget.currentUser?.authId;
      users.sort((a, b) {
        if (a.authId == currentId) return -1;
        if (b.authId == currentId) return 1;
        return a.profile.name.compareTo(b.profile.name);
      });
      setState(() {
        _allProfiles = users.map((user) => user.profile).toList();
        _currentUser = _allProfiles.first;
        _currentProfileIndex = _allProfiles.length > 1 ? 1 : 0;
      });
      await _loadProfileVideos();
    } catch (_) {
      // The current profile remains usable if browsing is unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedTab = widget.canViewAllProfiles ? _selectedTab : 0;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Profil')),
      body: Column(
        children: [
          if (widget.canViewAllProfiles)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: ModernTabSelector(
                labels: const ['Profil Saya', 'Lihat Profil'],
                icons: const [Icons.person_rounded, Icons.people_alt_rounded],
                selectedIndex: _selectedTab,
                onChanged: (index) => setState(() => _selectedTab = index),
              ),
            ),
          Expanded(
            child: selectedTab == 0
                ? _buildMyProfileTab()
                : _buildBrowseProfilesTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildMyProfileTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      child: Column(
        children: [
          ProfileHeader(
            name: _currentUser.name,
            subtitle: 'Anggota Aktif',
            avatarImage: imageFile != null ? FileImage(imageFile!) : null,
            onAvatarTap: pickImage,
            stats: [
              ProfileStat(
                label: 'Hobi',
                value: '${_hobbyItems(_currentUser).length}',
              ),
              ProfileStat(
                label: 'Video',
                value: profileVideos[_currentUser.id] != null ? 'Ada' : '0',
              ),
              ProfileStat(label: 'Bergabung', value: _currentUser.joinDate),
            ],
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: pickImage,
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text("Ganti Foto"),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.info_outline_rounded,
            title: 'Tentang Saya',
            child: _SoftPanel(child: Text(_currentUser.bio)),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.video_library_rounded,
            title: 'Video Perkenalan',
            child: _VideoSelector(
              file: profileVideos[_currentUser.id],
              onPick: pickVideo,
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.favorite_rounded,
            title: 'Hobi',
            child: _HobbyWrap(hobbies: _hobbyItems(_currentUser)),
          ),
          const SizedBox(height: 16),
          _JoinDateCard(joinDate: _currentUser.joinDate),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showEditDialog(_currentUser, 0),
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit Profil'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseProfilesTab() {
    if (_currentProfileIndex >= _allProfiles.length) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CustomCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 64,
                  color: AppPalette.navy,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tidak ada profil lagi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() => _currentProfileIndex = 1),
                  child: const Text('Kembali ke Awal'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final profile = _allProfiles[_currentProfileIndex];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      child: Column(
        children: [
          ProfileHeader(
            name: profile.name,
            subtitle: 'Member',
            stats: [
              ProfileStat(label: 'Profil', value: '$_currentProfileIndex'),
              ProfileStat(
                label: 'Video',
                value: profileVideos[profile.id] != null ? 'Ada' : '0',
              ),
              ProfileStat(label: 'Bergabung', value: profile.joinDate),
            ],
          ),
          const SizedBox(height: 20),
          _InfoCard(
            icon: Icons.info_outline_rounded,
            title: 'Tentang',
            child: _SoftPanel(child: Text(profile.bio)),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.video_library_rounded,
            title: 'Video Perkenalan',
            child: _VideoSelector(
              file: profileVideos[profile.id],
              onPick: () => pickVideoForProfile(profile.id),
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.favorite_rounded,
            title: 'Hobi',
            child: _HobbyWrap(hobbies: _hobbyItems(profile)),
          ),
          const SizedBox(height: 16),
          _JoinDateCard(joinDate: profile.joinDate),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (_currentProfileIndex > 1) {
                      setState(() => _currentProfileIndex--);
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Sebelumnya'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_currentProfileIndex < _allProfiles.length - 1) {
                      setState(() => _currentProfileIndex++);
                    }
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Berikutnya'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Profil $_currentProfileIndex dari ${_allProfiles.length - 1}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => _showEditDialog(profile, _currentProfileIndex),
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit Profil'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _hobbyItems(UserProfile profile) {
    return profile.hobby
        .split(',')
        .map((hobby) => hobby.trim())
        .where((hobby) => hobby.isNotEmpty)
        .toList();
  }

  Future<void> _showEditDialog(UserProfile profile, int profileIndex) async {
    final nameC = TextEditingController(text: profile.name);
    final bioC = TextEditingController(text: profile.bio);
    final hobbyC = TextEditingController(text: profile.hobby);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioC,
                decoration: const InputDecoration(
                  labelText: 'Tentang Saya',
                  hintText: 'Ceritakan tentang diri Anda...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hobbyC,
                decoration: const InputDecoration(
                  labelText: 'Hobi',
                  hintText: 'Pisahkan dengan koma: Coding, Traveling, Gaming',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedProfile = profile.copyWith(
                name: nameC.text,
                bio: bioC.text,
                hobby: hobbyC.text,
              );

              if (profileIndex == 0) {
                setState(() {
                  _currentUser = updatedProfile;
                });
                saveData();
              } else {
                _saveProfileData(profileIndex, updatedProfile);
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    nameC.dispose();
    bioC.dispose();
    hobbyC.dispose();
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBubble(icon: icon, color: AppPalette.navy, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SoftPanel extends StatelessWidget {
  final Widget child;

  const _SoftPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF111827)
            : AppPalette.softBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55),
        child: child,
      ),
    );
  }
}

class _VideoSelector extends StatefulWidget {
  final File? file;
  final VoidCallback onPick;

  const _VideoSelector({required this.file, required this.onPick});

  @override
  State<_VideoSelector> createState() => _VideoSelectorState();
}

class _VideoSelectorState extends State<_VideoSelector> {
  VideoPlayerController? _controller;
  Future<void>? _initializeFuture;
  bool _isPlaying = false;
  bool _fileMissing = false;

  @override
  void initState() {
    super.initState();
    _setupController();
  }

  @override
  void didUpdateWidget(covariant _VideoSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file?.path != widget.file?.path) {
      _setupController();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _setupController() {
    _disposeController();

    final file = widget.file;
    _fileMissing = false;
    _isPlaying = false;

    if (file == null) {
      return;
    }

    if (!file.existsSync()) {
      _fileMissing = true;
      return;
    }

    final controller = VideoPlayerController.file(file);
    _controller = controller;
    controller.addListener(_syncPlayingState);
    _initializeFuture = controller.initialize().then((_) async {
      await controller.setLooping(false);
      if (mounted && _controller == controller) {
        setState(() {});
      }
    });
  }

  void _disposeController() {
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_syncPlayingState);
      controller.dispose();
    }
    _controller = null;
    _initializeFuture = null;
  }

  void _syncPlayingState() {
    final controller = _controller;
    if (controller == null || !mounted) return;

    final isPlaying = controller.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() => _isPlaying = isPlaying);
    }
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() => _isPlaying = controller.value.isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.file?.path.split(RegExp(r'[\\/]')).last;
    return _SoftPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.file == null)
            const _VideoMessage(
              icon: Icons.movie_creation_rounded,
              text: 'Belum ada video yang dipilih.',
            )
          else if (_fileMissing)
            const _VideoMessage(
              icon: Icons.error_outline_rounded,
              text: 'Video tidak ditemukan. Pilih ulang video.',
            )
          else
            _buildVideoPreview(context, fileName),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: widget.onPick,
              icon: const Icon(Icons.video_library_rounded),
              label: Text(widget.file == null ? 'Pilih Video' : 'Ganti Video'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(BuildContext context, String? fileName) {
    final controller = _controller;
    final initializeFuture = _initializeFuture;

    if (controller == null || initializeFuture == null) {
      return const _VideoMessage(
        icon: Icons.error_outline_rounded,
        text: 'Video belum siap diputar.',
      );
    }

    return FutureBuilder<void>(
      future: initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _VideoMessage(
            icon: Icons.error_outline_rounded,
            text: 'Video tidak bisa diputar. Pilih video lain.',
          );
        }

        if (snapshot.connectionState != ConnectionState.done ||
            !controller.value.isInitialized) {
          return const AspectRatio(
            aspectRatio: 16 / 9,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final aspectRatio = controller.value.aspectRatio > 0
            ? controller.value.aspectRatio
            : 16 / 9;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                  Material(
                    color: Colors.black45,
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: _togglePlayback,
                      color: Colors.white,
                      iconSize: 34,
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      tooltip: _isPlaying ? 'Jeda video' : 'Putar video',
                    ),
                  ),
                ],
              ),
            ),
            if (fileName != null) ...[
              const SizedBox(height: 8),
              Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _VideoMessage extends StatelessWidget {
  final IconData icon;
  final String text;

  const _VideoMessage({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppPalette.navy),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _HobbyWrap extends StatelessWidget {
  final List<String> hobbies;

  const _HobbyWrap({required this.hobbies});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: hobbies.map((hobby) {
          return Chip(
            avatar: const Icon(Icons.favorite_rounded, size: 16),
            label: Text(hobby),
            backgroundColor: AppPalette.softBlue,
            labelStyle: const TextStyle(
              color: AppPalette.navy,
              fontWeight: FontWeight.w700,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _JoinDateCard extends StatelessWidget {
  final String joinDate;

  const _JoinDateCard({required this.joinDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const IconBubble(
            icon: Icons.calendar_today_rounded,
            color: AppPalette.navy,
            size: 48,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bergabung',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  joinDate,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
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
