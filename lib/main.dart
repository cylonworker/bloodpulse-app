import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uni_links/uni_links.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/blood_pressure_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/blood_pressure/blood_pressure_bloc.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/history_page.dart';
import 'presentation/pages/reports_page.dart';
import 'presentation/pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize Supabase with session persistence
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    debug: false,
  );

  runApp(const BloodPulseApp());
}

class BloodPulseApp extends StatefulWidget {
  const BloodPulseApp({super.key});

  @override
  State<BloodPulseApp> createState() => _BloodPulseAppState();
}

class _BloodPulseAppState extends State<BloodPulseApp> with WidgetsBindingObserver {
  StreamSubscription? _deepLinkSubscription;
  late final AuthRepository _authRepository;
  StreamSubscription<AuthStateEvent>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    final supabase = Supabase.instance.client;
    _authRepository = AuthRepositoryImpl(supabase);
    
    // Listen to auth state changes for session persistence
    _authStateSubscription = _authRepository.authStateChanges.listen((event) {
      // Auth state changes are handled by the BLoC
      // This listener ensures we catch token refresh events
    });
  }

  Future<void> _initDeepLinks() async {
    // Handle app being opened via deep link
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to get initial URI: $e');
    }

    // Handle deep links while app is running
    _deepLinkSubscription = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Received deep link: $uri');
    // The deep link will be processed by the AuthBloc
    // We need to emit an event to the BLoC, but since BLoC is created in build,
    // we'll store it temporarily and process it when BLoC is available
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    _authStateSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepositoryImpl(supabase)),
        RepositoryProvider(create: (_) => BloodPressureRepositoryImpl(supabase)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepositoryImpl>())..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => BloodPressureBloc(context.read<BloodPressureRepositoryImpl>()),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  int _currentIndex = 0;
  StreamSubscription? _deepLinkSub;

  final List<Widget> _pages = const [
    HomePage(),
    HistoryPage(),
    ReportsPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    // Listen for deep links and forward to BLoC
    _deepLinkSub = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null && mounted) {
          context.read<AuthBloc>().add(DeepLinkReceived(uri));
        }
      },
      onError: (err) {
        debugPrint('AuthWrapper deep link error: $err');
      },
    );
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: state.code == 'user_exists'
                  ? SnackBarAction(
                      label: 'SIGN IN',
                      textColor: Colors.white,
                      onPressed: () {
                        // Switch to sign in mode - handled by login page
                      },
                    )
                  : null,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Checking session...'),
                  ],
                ),
              ),
            );
          }

          if (state is AuthNeedsEmailConfirmation) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.email_outlined, size: 64, color: Colors.orange),
                      const SizedBox(height: 24),
                      const Text(
                        'Check Your Email',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'We\'ve sent a confirmation email to ${state.email}. Please check your inbox and click the confirmation link.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthCheckRequested());
                        },
                        child: const Text('I\'ve Confirmed My Email'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is AuthAuthenticated) {
            // Initialize SettingsBloc with user ID
            return BlocProvider(
              create: (_) => SettingsBloc()..add(SettingsLoadRequested(state.user.id)),
              child: Scaffold(
                body: IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.history_outlined),
                      selectedIcon: Icon(Icons.history),
                      label: 'History',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.description_outlined),
                      selectedIcon: Icon(Icons.description),
                      label: 'Reports',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                  ],
                ),
              ),
            );
          }

          return const LoginPage();
        },
      ),
    );
  }
}