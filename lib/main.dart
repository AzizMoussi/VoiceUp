import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/conversations/conversations_list_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDom5rOFV6omlcsWIGuo7e71jyWMvr1EcU",
        projectId: "voiceup-2718a",
        messagingSenderId: "966451651200",
        appId: "1:966451651200:web:8fe4f8072f4c039397bc65",
        storageBucket: "voiceup-2718a.firebasestorage.app",
      ),
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://kuzcitbdnqscjauxszgk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt1emNpdGJkbnFzY2phdXhzemdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc0ODA2NzgsImV4cCI6MjA4MzA1NjY3OH0.ttL4nIgo-AXawUleLB0WebGKqP85j5DH-NuaR8VUnts',
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
