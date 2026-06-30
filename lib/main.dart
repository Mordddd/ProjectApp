import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'models/app_user.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';
import 'services/permission_repository.dart';
import 'services/permission_service.dart';
import 'theme/app_theme.dart';
import 'widgets/app_components.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([SupabaseConfig.initialize(), ThemeController.load()]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Learning Hub',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          home: const AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();
  late Future<AppUser?> _currentUserFuture;

  @override
  void initState() {
    super.initState();
    _currentUserFuture = _loadSession();
  }

  Future<AppUser?> _loadSession() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      await PermissionService.initialize(
        repository: SupabaseConfig.isConfigured
            ? SupabasePermissionRepository()
            : null,
        user: user,
      );
    }
    return user;
  }

  void _refreshSession() {
    setState(() {
      _currentUserFuture = _loadSession();
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    _refreshSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: _currentUserFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashScreen();
        }

        if (snapshot.hasError) {
          return _StartupError(
            message: snapshot.error.toString(),
            onRetry: _refreshSession,
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return LoginPage(onLoginSuccess: (_) => _refreshSession());
        }

        return HomePage(user: user, onLogout: _logout);
      },
    );
  }
}

class _StartupError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _StartupError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AppBackdrop(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CustomCard(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const IconBubble(
                        icon: Icons.cloud_off_rounded,
                        color: AppPalette.navy,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aplikasi belum dapat dimuat',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Periksa koneksi atau konfigurasi layanan, lalu coba lagi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: const Text('Detail teknis'),
                        children: [
                          SelectableText(
                            message,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppBackdrop(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconBubble(
                icon: Icons.auto_stories_rounded,
                color: AppPalette.navy,
                size: 72,
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(strokeWidth: 3),
              SizedBox(height: 14),
              Text(
                'Menyiapkan Learning Hub',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
