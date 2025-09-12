import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'presentation/views/landing_view.dart';
import 'presentation/views/workspace_dashboard_view.dart';
import 'presentation/views/auth/login_view.dart';
import 'presentation/views/auth/signup_view.dart';
import 'core/theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'models/auth_state_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with proper options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthController())],
      child: MaterialApp(
        title: 'Clauselens',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Enable web support
        builder: (context, child) {
          // Add responsive support for web
          if (kIsWeb) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          }
          return child!;
        },
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginView(),
          '/signup': (context) => const SignupView(),
          '/dashboard': (context) => const WorkspaceDashboardView(),
        },
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
  @override
  void initState() {
    super.initState();
    // Check authentication status on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        // Show loading screen while checking auth status
        if (authController.authState.status == AuthStatus.loading) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundWhite,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentBlue),
              ),
            ),
          );
        }

        // Show appropriate page based on authentication status
        if (authController.authState.isAuthenticated) {
          return const WorkspaceDashboardView();
        } else {
          return const LandingView();
        }
      },
    );
  }
}
