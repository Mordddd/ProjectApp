import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedTab = 0; // 0: My Profile, 1: Browse Profiles

  // Current User Data
  late UserProfile _currentUser;
  File? imageFile;
  File? videoFile;
  final picker = ImagePicker();

  // Browse profiles
  late List<UserProfile> _allProfiles;
  int _currentProfileIndex = 1; // Start from index 1 (other users)

  @override
  void initState() {
    super.initState();
    _initializeProfiles();
    loadData();
  }

  void _initializeProfiles() {
    _allProfiles = UserProfile.getMockProfiles();
    _currentUser = _allProfiles[0]; // First profile is current user
  }

  // 📥 LOAD
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _currentUser = _currentUser.copyWith(
        name: prefs.getString('profile_name') ?? _currentUser.name,
        bio: prefs.getString('profile_bio') ?? _currentUser.bio,
        hobby: prefs.getString('profile_hobby') ?? _currentUser.hobby,
      );

      String? imagePath = prefs.getString('profile_image');
      if (imagePath != null) imageFile = File(imagePath);
    });
  }

  // 💾 SAVE
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('profile_name', _currentUser.name);
    await prefs.setString('profile_bio', _currentUser.bio);
    await prefs.setString('profile_hobby', _currentUser.hobby);

    if (imageFile != null) {
      await prefs.setString('profile_image', imageFile!.path);
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile tersimpan!")));
    }
  }

  // 📸 PICK IMAGE
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future <void> pickVideo() async {
    final picked = await picker.pickVideo(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        videoFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0E5),
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: const Color(0xFF082052),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Tab Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? const Color(0xFF3B82F6)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Profil Saya',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedTab == 0
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? const Color(0xFF3B82F6)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Lihat Profil',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedTab == 1
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? _buildMyProfileTab()
                : _buildBrowseProfilesTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildMyProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6),
                          const Color(0xFF3B82F6).withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: imageFile != null
                          ? FileImage(imageFile!)
                          : null,
                      child: imageFile == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF3B82F6),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Ganti Foto"),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentUser.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Active Member',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Bio Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tentang Saya',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _currentUser.bio,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Video Perkenalan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        videoFile != null
                            ? Text('Video terpilih: ${videoFile!.path.split('/').last}')
                            : const Text('Belum ada video yang dipilih.'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: pickVideo,
                          icon: const Icon(Icons.video_library),
                          label: const Text("Pilih Video"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Hobby Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      const Text(
                        'Hobi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _currentUser.hobby.split(',').map((hobby) {
                      return Chip(
                        label: Text(hobby.trim()),
                        backgroundColor: const Color(
                          0xFFF3B0F6,
                        ).withOpacity(0.2),
                        labelStyle: const TextStyle(color: Color(0xFF8B5CF6)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Join Date
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF08A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bergabung',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        _currentUser.joinDate,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Edit Button
          ElevatedButton.icon(
            onPressed: _showEditDialog,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseProfilesTab() {
    if (_currentProfileIndex >= _allProfiles.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_outline,
              size: 64,
              color: Color(0xFFD1D5DB),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada profil lagi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _currentProfileIndex = 1),
              child: const Text('Kembali ke Awal'),
            ),
          ],
        ),
      );
    }

    final profile = _allProfiles[_currentProfileIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '👤 Member',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Bio
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tentang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      profile.bio,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

            Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Video Perkenalan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        videoFile != null
                            ? Text('Video terpilih: ${videoFile!.path.split('/').last}')
                            : const Text('Belum ada video yang dipilih.'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: pickVideo,
                          icon: const Icon(Icons.video_library),
                          label: const Text("Pilih Video"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Hobi
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Hobi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: profile.hobby.split(',').map((hobby) {
                      return Chip(
                        label: Text(hobby.trim()),
                        backgroundColor: const Color(
                          0xFFF3B0F6,
                        ).withOpacity(0.2),
                        labelStyle: const TextStyle(color: Color(0xFF8B5CF6)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Join Date
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF08A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bergabung',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        profile.joinDate,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (_currentProfileIndex > 1) {
                      setState(() => _currentProfileIndex--);
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Sebelumnya'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
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
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Berikutnya'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Profil ${_currentProfileIndex} dari ${_allProfiles.length - 1}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    TextEditingController nameC = TextEditingController(
      text: _currentUser.name,
    );
    TextEditingController bioC = TextEditingController(text: _currentUser.bio);
    TextEditingController hobbyC = TextEditingController(
      text: _currentUser.hobby,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioC,
                decoration: const InputDecoration(
                  labelText: 'Tentang Saya',
                  border: OutlineInputBorder(),
                  hintText: 'Ceritakan tentang diri Anda...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hobbyC,
                decoration: const InputDecoration(
                  labelText: 'Hobi',
                  border: OutlineInputBorder(),
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
              setState(() {
                _currentUser = _currentUser.copyWith(
                  name: nameC.text,
                  bio: bioC.text,
                  hobby: hobbyC.text,
                );
              });
              saveData();
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
