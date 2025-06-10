import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:printer/features/auth/presentation/pages/nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/onboarding_screen.dart';
import 'features/home_screen.dart';

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  MyApp({super.key, required this.prefs});
  final ThemeData appTheme = ThemeData(
    colorScheme: ColorScheme.light(
      surface: Color(0xFFF5F5F7),
      primary: Color(0xFF0012b1),
      secondary: Color(0xFFff4700),
      tertiary: Color(0xFFE0E6ED),
      inversePrimary: Color(0xFF6EE2F5),
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF001F3F)),
      titleTextStyle: TextStyle(
        color: Color(0xFF001F3F),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: IconThemeData(color: Color(0xFF415A77)),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF001F3F)),
      bodyMedium: TextStyle(color: Color(0xFF415A77)),
    ),
  );



  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => AuthRepository(),
      child: BlocProvider(
        create: (context) => AuthBloc(authRepository: context.read<AuthRepository>())..add(CheckAuthEvent()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: appTheme, // Teman neyse
          home: const InitialPage(), // Değişiklik burada
        ),
      ),
    );
  }
}

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  bool _isLoading = true;
  bool _seenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;

    setState(() {
      _seenOnboarding = seen;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _seenOnboarding ? const SplashScreen() : const OnboardingPage();
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigated = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _authSubscription?.cancel(); // Stream dinleyicisini iptal et
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return; // widget hâlâ ekranda mı?

    final authCubit = context.read<AuthBloc>();
    final authState = authCubit.state;

    if (authState is Authenticated || authState is Unauthenticated) {
      _navigateNext();
    } else {
      _authSubscription = authCubit.stream.listen((state) {
        if (!mounted) return;
        if (!_isNavigated &&
            (state is Authenticated || state is Unauthenticated)) {
          _navigateNext();
        }
      });
    }
  }

  void _navigateNext() {
    if (!_isNavigated && mounted) {
      _isNavigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: Center(
        child: Lottie.asset(
          'assets/lotties/splash.json',
          width: 400,
          height: 400,
          fit: BoxFit.contain,
          repeat: true,
        ),
      ),
    );
  }
}
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is Unauthenticated) {
          return LoginScreen();
        }
        if (state is Authenticated) {
          return const NavBar();
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
