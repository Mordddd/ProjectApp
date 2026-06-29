import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'models/app_user.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';
import 'services/permission_repository.dart';
import 'services/permission_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    ThemeController.load();
  }

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
            ? SupabasePermissionRepository(SupabaseConfig.client)
            : LocalPermissionRepository(),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48),
              const SizedBox(height: 12),
              const Text('Gagal memuat data aplikasi.'),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Coba lagi'),
              ),
            ],
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
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
