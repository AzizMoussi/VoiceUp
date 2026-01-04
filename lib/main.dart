import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/conversations/conversations_list_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: AppConfig.firebaseApiKey,
        projectId: AppConfig.firebaseProjectId,
        messagingSenderId: AppConfig.firebaseMessagingSenderId,
        appId: AppConfig.firebaseAppId,
        storageBucket: AppConfig.firebaseStorageBucket,
      ),
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VoiceUp',
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            print('🔵 Main: Building home screen');
            print('   Status: ${authProvider.status}');
            print('   IsAuthenticated: ${authProvider.isAuthenticated}');
            print('   CurrentUser: ${authProvider.currentUser?.email}');

            // Show loading while checking auth state
            if (authProvider.status == AuthStatus.initial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Show appropriate screen based on auth state
            // Must check both isAuthenticated AND currentUser is not null
            if (authProvider.isAuthenticated &&
                authProvider.currentUser != null) {
              return const ConversationsListScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
