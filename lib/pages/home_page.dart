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
      subtitle: 'Voting hobi favorit',
      accent: const Color(0xFFEC4899),
      open: (context) => _push(context, const PollPage()),
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

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
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
      body: IndexedStack(index: _selectedIndex, children: pages),
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
    final featured = _filteredFeatures.take(6).toList();
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
                _StaggeredIn(delay: 20, child: _WelcomeCard(user: widget.user)),
                const SizedBox(height: 18),
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
                const SizedBox(height: 24),
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
          Row(
            children: [
              IconButton(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Logout',
              ),
              const Spacer(),
              Text(
                'Home',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
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
            ],
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Learning Hub',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hi, $userName',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$roleLabel - ${divisionName.isEmpty ? 'Tanpa divisi' : divisionName}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: controller,
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari fitur...',
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

class _WelcomeCard extends StatelessWidget {
  final AppUser user;

  const _WelcomeCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user.profile.nama.isEmpty ? user.username : user.profile.nama}!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppPalette.navy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Status ${user.statusLabel}. Jelajahi fitur sesuai akses ${user.levelUser.label}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: AppPalette.softBlue,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: AppPalette.navy,
              size: 42,
            ),
          ),
        ],
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
          IconBubble(icon: icon, color: AppPalette.navy),
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
                  color: AppPalette.navy,
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

class _QuickAction extends StatelessWidget {
  final _FeatureItem item;
  final ValueChanged<_FeatureItem> onOpen;

  const _QuickAction({required this.item, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Pressable(
      onTap: () => onOpen(item),
      child: SizedBox(
        width: 88,
        child: Column(
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
