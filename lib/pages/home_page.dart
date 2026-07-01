import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/permission.dart';
import '../services/permission_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/permission_guard.dart';
import 'bilangan_page.dart';
import 'calculator_page.dart';
import 'create_account_page.dart';
import 'discount_page.dart';
import 'max_min_page.dart';
import 'multi_quiz_page.dart';
import 'permission_management_page.dart';
import 'unauthorized_page.dart';
import 'poll_page.dart';
import 'profile_page.dart';
import 'quiz_page.dart';
import 'sorting_page.dart';
import 'zodiac_page.dart';

class HomePage extends StatefulWidget {
  final AppUser user;
  final Future<void> Function() onLogout;

  const HomePage({super.key, required this.user, required this.onLogout});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _query = '';
  final _searchController = TextEditingController();

  late final List<_FeatureItem> _features = [
    _FeatureItem(
      feature: PermissionFeature.profile,
      icon: Icons.person_rounded,
      title: 'Profile',
      subtitle: 'Kelola profil dan video anggota',
      accent: AppPalette.navy,
      open: (context) => _selectTab(1),
    ),
    _FeatureItem(
      feature: PermissionFeature.quiz,
      icon: Icons.quiz_rounded,
      title: 'Quiz',
      subtitle: 'Latihan soal interaktif',
      accent: const Color(0xFF315C99),
      open: (context) => _selectTab(2),
    ),
    _FeatureItem(
      feature: PermissionFeature.multiQuiz,
      icon: Icons.checklist_rounded,
      title: 'Multi Quiz',
      subtitle: 'Pilih beberapa jawaban',
      accent: const Color(0xFFF59E0B),
      open: (context) => _push(context, const MultiQuizPage()),
    ),
    _FeatureItem(
      feature: PermissionFeature.calculator,
      icon: Icons.calculate_rounded,
      title: 'Calculator',
      subtitle: 'Operasi angka dan bentuk',
      accent: const Color(0xFF10B981),
      open: (context) => _push(context, const CalculatorPage()),
    ),
    _FeatureItem(
      feature: PermissionFeature.polling,
      icon: Icons.poll_rounded,
      title: 'Polling',
      subtitle: 'Dashboard data kelas',
      accent: const Color(0xFFEC4899),
      open: (context) => _push(context, PollPage(currentUser: widget.user)),
    ),
    _FeatureItem(
      feature: PermissionFeature.maxMin,
      icon: Icons.maximize_rounded,
      title: 'Max & Min',
      subtitle: 'Cari nilai terbesar dan terkecil',
      accent: const Color(0xFF0EA5E9),
      open: (context) => _push(context, const MaxMinPage()),
    ),
    _FeatureItem(
      feature: PermissionFeature.discount,
      icon: Icons.discount_rounded,
      title: 'Discount',
      subtitle: 'Hitung diskon belanja',
      accent: const Color(0xFFEF4444),
      open: (context) => _push(context, const DiscountPage()),
    ),
    _FeatureItem(
      feature: PermissionFeature.bilangan,
      icon: Icons.numbers_rounded,
      title: 'Bilangan',
      subtitle: 'Kenali jenis bilangan',
      accent: const Color(0xFF22C55E),
      open: (context) => _push(context, const BilanganPage()),
    ),
    _FeatureItem(
      feature: PermissionFeature.sorting,
      icon: Icons.sort_rounded,
      title: 'Sorting',
      subtitle: 'Urutkan data angka',
      accent: const Color(0xFF6366F1),
      open: (context) => _push(context, const SortingPage()),
    ),
    _FeatureItem(
      feature: PermissionFeature.zodiac,
      icon: Icons.auto_awesome_rounded,
      title: 'Zodiac',
      subtitle: 'Cek zodiak dari tanggal lahir',
      accent: const Color(0xFF7C3AED),
      open: (context) => _push(context, const ZodiacPage()),
    ),
    _FeatureItem(
      feature: PermissionFeature.createAccount,
      icon: Icons.person_add_alt_1_rounded,
      title: 'Create Account',
      subtitle: 'Tambah user baru',
      accent: const Color(0xFF0F766E),
      open: (context) =>
          _push(context, CreateAccountPage(currentUser: widget.user)),
    ),
    _FeatureItem(
      feature: PermissionFeature.accessControl,
      icon: Icons.admin_panel_settings_rounded,
      title: 'Access Control',
      subtitle: 'Kelola izin fitur tiap role',
      accent: const Color(0xFF082052),
      open: (context) async {
        await _push(
          context,
          PermissionManagementPage(currentUser: widget.user),
        );
        if (mounted) setState(() {});
      },
    ),
  ];

  void _selectTab(int index) {
    final feature = _featureForTab(index);
    if (feature != null && !PermissionService.canAccess(widget.user, feature)) {
      _pushUnauthorized(context, feature);
      return;
    }

    setState(() => _selectedIndex = index);
  }

  PermissionFeature? _featureForTab(int index) {
    switch (index) {
      case 1:
        return PermissionFeature.profile;
      case 2:
        return PermissionFeature.quiz;
      default:
        return null;
    }
  }

  void _openFeature(BuildContext context, _FeatureItem item) {
    if (!PermissionService.canAccess(widget.user, item.feature)) {
      _pushUnauthorized(context, item.feature);
      return;
    }

    item.open(context);
  }

  Future<void> _push(BuildContext context, Widget page) async {
    await Navigator.of(context).push<void>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _pushUnauthorized(BuildContext context, PermissionFeature feature) {
    _push(context, UnauthorizedPage(user: widget.user, feature: feature));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(context),
      PermissionGuard(
        user: widget.user,
        feature: PermissionFeature.profile,
        child: ProfilePage(
          currentUser: widget.user,
          canViewAllProfiles: PermissionService.canAccess(
            widget.user,
            PermissionFeature.viewAllProfiles,
          ),
        ),
      ),
      PermissionGuard(
        user: widget.user,
        feature: PermissionFeature.quiz,
        child: const QuizPage(),
      ),
      _buildCategoriesPage(context),
    ];

    return Scaffold(
      extendBody: true,
      body: AppBackdrop(
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Semua fitur',
        onPressed: () => _selectTab(3),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: _selectedIndex,
        onSelected: _selectTab,
        items: const [
          BottomNavEntry(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: 'Home',
          ),
          BottomNavEntry(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: 'Profile',
          ),
          BottomNavEntry(
            icon: Icons.school_outlined,
            selectedIcon: Icons.school_rounded,
            label: 'Quiz',
          ),
          BottomNavEntry(
            icon: Icons.apps_outlined,
            selectedIcon: Icons.apps_rounded,
            label: 'Fitur',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = width < 390 ? 16.0 : 20.0;
    final featured = _filteredFeatures.take(4).toList();
    final userName = widget.user.profile.namaLengkap.isEmpty
        ? widget.user.username
        : widget.user.profile.namaLengkap;
    final accessCount = _visibleFeatures.length;
    final progress = _features.isEmpty
        ? 0.0
        : (accessCount / _features.length * 100).clamp(0, 100).toDouble();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _HomeHeader(
              userName: userName,
              roleLabel: widget.user.levelUser.label,
              divisionName: widget.user.profile.namaDivisi,
              query: _query,
              controller: _searchController,
              onQueryChanged: (value) => setState(() => _query = value),
              onClear: () {
                _searchController.clear();
                setState(() => _query = '');
              },
              onLogout: widget.onLogout,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(padding, 12, padding, 118),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_query.isEmpty) ...[
                  _StaggeredIn(
                    delay: 20,
                    child: _HeroCard(
                      user: widget.user,
                      primaryLabel:
                          PermissionService.canAccess(
                            widget.user,
                            PermissionFeature.quiz,
                          )
                          ? 'Mulai quiz'
                          : 'Mulai belajar',
                      onPrimary: () {
                        if (PermissionService.canAccess(
                          widget.user,
                          PermissionFeature.quiz,
                        )) {
                          _selectTab(2);
                        } else if (_visibleFeatures.isNotEmpty) {
                          _openFeature(context, _visibleFeatures.first);
                        }
                      },
                      onExplore: () => _selectTab(3),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
                SectionHeader(
                  title: _query.isEmpty ? 'Fitur populer' : 'Hasil pencarian',
                  action: 'Lihat semua',
                  onAction: () => _selectTab(3),
                ),
                const SizedBox(height: 12),
                if (featured.isEmpty)
                  _EmptySearch(query: _query)
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width < 520 ? 2 : 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: width < 380 ? 0.86 : 0.96,
                    ),
                    itemCount: featured.length,
                    itemBuilder: (context, index) {
                      final item = featured[index];
                      return _StaggeredIn(
                        delay: 40 * index,
                        child: FeatureCard(
                          icon: item.icon,
                          title: item.title,
                          subtitle: item.subtitle,
                          color: item.accent,
                          onTap: () => _openFeature(context, item),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _StaggeredIn(
                        delay: 50,
                        child: _StatCard(
                          icon: Icons.menu_book_rounded,
                          title: 'Akses',
                          value: '$accessCount',
                          subtitle: 'Fitur',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StaggeredIn(
                        delay: 80,
                        child: _StatCard(
                          icon: Icons.quiz_rounded,
                          title: 'Level',
                          value: '${widget.user.idLevelUser}',
                          subtitle: widget.user.levelUser.label,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _StaggeredIn(
                  delay: 120,
                  child: _ProgressCard(progress: progress),
                ),
                const SizedBox(height: 32),
                const _LearningCueCarousel(),
                const SizedBox(height: 32),
                SectionHeader(
                  title: 'Akses cepat',
                  action: 'Semua fitur',
                  onAction: () => _selectTab(3),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 98,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _visibleFeatures.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return _QuickAction(
                        item: _visibleFeatures[index],
                        onOpen: (item) => _openFeature(context, item),
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesPage(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = width < 390 ? 16.0 : 20.0;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(padding, 20, padding, 118),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _CategoriesHeader(total: _visibleFeatures.length),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: width < 520 ? 2 : 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: width < 380 ? 0.86 : 0.96,
                  ),
                  itemCount: _visibleFeatures.length,
                  itemBuilder: (context, index) {
                    final item = _visibleFeatures[index];
                    return _StaggeredIn(
                      delay: 30 * index,
                      child: FeatureCard(
                        icon: item.icon,
                        title: item.title,
                        subtitle: item.subtitle,
                        color: item.accent,
                        onTap: () => _openFeature(context, item),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<_FeatureItem> get _filteredFeatures {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return _visibleFeatures;

    return _visibleFeatures.where((feature) {
      return feature.title.toLowerCase().contains(normalized) ||
          feature.subtitle.toLowerCase().contains(normalized);
    }).toList();
  }

  List<_FeatureItem> get _visibleFeatures {
    return _features
        .where(
          (feature) =>
              PermissionService.canAccess(widget.user, feature.feature),
        )
        .toList(growable: false);
  }
}

class _FeatureItem {
  final PermissionFeature feature;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final void Function(BuildContext context) open;

  const _FeatureItem({
    required this.feature,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.open,
  });
}

class _HomeHeader extends StatelessWidget {
  final String userName;
  final String roleLabel;
  final String divisionName;
  final String query;
  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final Future<void> Function() onLogout;

  const _HomeHeader({
    required this.userName,
    required this.roleLabel,
    required this.divisionName,
    required this.query,
    required this.controller,
    required this.onQueryChanged,
    required this.onClear,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Column(
        children: [
          CustomCard(
            padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
            radius: 24,
            shadows: const [],
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: colors.onPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Learning Hub',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '$roleLabel  ·  ${divisionName.isEmpty ? 'Tanpa divisi' : divisionName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeController.mode,
                  builder: (context, mode, _) {
                    return Tooltip(
                      message: isDark ? 'Mode terang' : 'Mode gelap',
                      child: IconButton.filledTonal(
                        onPressed: ThemeController.toggle,
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            isDark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            key: ValueKey(mode),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  tooltip: 'Menu akun',
                  icon: const Icon(Icons.more_horiz_rounded),
                  onSelected: (value) {
                    if (value == 'logout') onLogout();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded),
                          SizedBox(width: 10),
                          Text('Keluar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari fitur untuk $userName',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final AppUser user;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onExplore;

  const _HeroCard({
    required this.user,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = user.profile.nama.isEmpty
        ? user.username
        : user.profile.nama;

    return CustomCard(
      color: const Color(0xD9082052),
      radius: 32,
      padding: EdgeInsets.zero,
      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final fontSize = (constraints.maxWidth * (wide ? 0.052 : 0.095))
              .clamp(31.0, 52.0);

          final copy = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $displayName',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Belajar lebih fokus '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        width: fontSize * 1.25,
                        height: fontSize * 0.58,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8FD8FF), Color(0xFFBFA7FF)],
                          ),
                        ),
                        child: Icon(
                          Icons.trending_up_rounded,
                          color: AppPalette.navy,
                          size: fontSize * 0.38,
                        ),
                      ),
                    ),
                    const TextSpan(text: '\ncapai lebih banyak.'),
                  ],
                ),
                maxLines: 3,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontSize: fontSize,
                  height: 1.02,
                  letterSpacing: -1.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Satu ruang untuk latihan, perhitungan, dan eksplorasi materi sesuai aksesmu.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.76),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 26),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: onPrimary,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(primaryLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppPalette.navy,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onExplore,
                    icon: const Icon(Icons.grid_view_rounded),
                    label: const Text('Jelajahi fitur'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.48),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );

          final visual = SizedBox(
            height: wide ? 270 : 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: -0.15,
                  child: Container(
                    width: wide ? 220 : 180,
                    height: wide ? 220 : 170,
                    decoration: BoxDecoration(
                      color: const Color(0xFF88D7FF).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(38),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: 0.12,
                  child: Container(
                    width: wide ? 190 : 155,
                    height: wide ? 190 : 145,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.30),
                          Colors.white.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 72,
                    ),
                  ),
                ),
              ],
            ),
          );

          return Padding(
            padding: EdgeInsets.all(wide ? 34 : 24),
            child: wide
                ? Row(
                    children: [
                      Expanded(flex: 6, child: copy),
                      const SizedBox(width: 30),
                      Expanded(flex: 4, child: visual),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [copy, const SizedBox(height: 16), visual],
                  ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBubble(icon: icon, color: theme.colorScheme.primary),
          const SizedBox(height: 14),
          Text(title, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 5,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(subtitle, style: theme.textTheme.labelMedium),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final double progress;

  const _ProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      padding: const EdgeInsets.all(18),
      color: AppPalette.navy,
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Learning Progress',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${progress.toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress / 100),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 9,
                  color: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LearningCueCarousel extends StatefulWidget {
  const _LearningCueCarousel();

  @override
  State<_LearningCueCarousel> createState() => _LearningCueCarouselState();
}

class _LearningCueCarouselState extends State<_LearningCueCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  int _index = 0;

  static const _cues = [
    (
      title: 'Mulai dari satu latihan kecil',
      body: 'Konsistensi singkat setiap hari lebih mudah dipertahankan.',
      icon: Icons.bolt_rounded,
    ),
    (
      title: 'Uji pemahamanmu',
      body:
          'Gunakan quiz setelah belajar untuk menemukan bagian yang belum kuat.',
      icon: Icons.psychology_alt_rounded,
    ),
    (
      title: 'Lihat pola pada data',
      body:
          'Bandingkan hasil, urutan, dan grafik untuk memahami konsep lebih cepat.',
      icon: Icons.insights_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _move(int delta) {
    final next = (_index + delta).clamp(0, _cues.length - 1);
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Ritme belajar yang lebih baik',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton.outlined(
              tooltip: 'Sebelumnya',
              onPressed: _index == 0 ? null : () => _move(-1),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Berikutnya',
              onPressed: _index == _cues.length - 1 ? null : () => _move(1),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 148,
          child: PageView.builder(
            controller: _controller,
            itemCount: _cues.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) {
              final cue = _cues[index];
              final selected = index == _index;
              return AnimatedScale(
                scale: selected ? 1 : 0.94,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CustomCard(
                    shadows: selected ? AppShadows.soft(context) : const [],
                    child: Row(
                      children: [
                        IconBubble(
                          icon: cue.icon,
                          color: theme.colorScheme.primary,
                          size: 58,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cue.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cue.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatefulWidget {
  final _FeatureItem item;
  final ValueChanged<_FeatureItem> onOpen;

  const _QuickAction({required this.item, required this.onOpen});

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    return MouseRegion(
      onEnter: (_) => setState(() => _expanded = true),
      onExit: (_) => setState(() => _expanded = false),
      child: _Pressable(
        onTap: () => widget.onOpen(item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: _expanded ? 190 : 88,
          padding: EdgeInsets.symmetric(
            horizontal: _expanded ? 12 : 0,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _expanded
                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: _expanded
              ? Row(
                  children: [
                    IconBubble(icon: item.icon, color: item.accent, size: 54),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            item.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    IconBubble(icon: item.icon, color: item.accent, size: 56),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CategoriesHeader extends StatelessWidget {
  final int total;

  const _CategoriesHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      color: AppPalette.navy,
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      child: Row(
        children: [
          IconBubble(
            icon: Icons.apps_rounded,
            color: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Semua Fitur',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total fitur siap digunakan',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.76),
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

class _EmptySearch extends StatelessWidget {
  final String query;

  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      child: Row(
        children: [
          Icon(Icons.search_off_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tidak ada fitur untuk "$query".',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StaggeredIn extends StatelessWidget {
  final int delay;
  final Widget child;

  const _StaggeredIn({required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _Pressable({required this.child, required this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: widget.child,
      ),
    );
  }
}
