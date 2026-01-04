// Import des packages Flutter et des bibliothèques externes
import 'package:flutter/material.dart'; // Material Design components
import 'package:firebase_core/firebase_core.dart'; // Firebase Core pour initialisation
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase pour stockage audio
import 'package:provider/provider.dart'; // State management
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Chargement variables d'environnement

// Import des fichiers de l'application
import 'core/config/app_config.dart'; // Configuration (clés API)
import 'providers/auth_provider.dart'; // Provider d'authentification
import 'providers/chat_provider.dart'; // Provider de messagerie
import 'presentation/screens/auth/login_screen.dart'; // Écran de connexion
import 'presentation/screens/conversations/conversations_list_screen.dart'; // Liste conversations
import 'core/theme/app_theme.dart'; // Thème de l'application

/// main() - Point d'entrée de l'application
/// Fonction asynchrone pour permettre les initialisations async
void main() async {
  // WidgetsFlutterBinding.ensureInitialized()
  // IMPORTANT: Nécessaire avant toute opération async dans main()
  // Initialise la liaison entre Flutter et le système d'exploitation
  WidgetsFlutterBinding.ensureInitialized();

  // ========== CHARGEMENT DES VARIABLES D'ENVIRONNEMENT ==========
  // Charge le fichier .env contenant les clés API (sécurité)
  await dotenv.load(fileName: ".env");

  // ========== INITIALISATION FIREBASE ==========
  // Firebase: Backend pour authentification et base de données (Firestore)
  try {
    await Firebase.initializeApp(
      // FirebaseOptions: Configuration Firebase avec les clés du .env
      options: FirebaseOptions(
        apiKey: AppConfig.firebaseApiKey, // Clé API Firebase
        projectId: AppConfig.firebaseProjectId, // ID du projet
        messagingSenderId:
            AppConfig.firebaseMessagingSenderId, // ID pour notifications
        appId: AppConfig.firebaseAppId, // ID de l'application
        storageBucket: AppConfig.firebaseStorageBucket, // Bucket de stockage
      ),
    );
  } catch (e) {
    // En cas d'erreur, afficher dans la console (ne bloque pas l'app)
    print('Firebase initialization error: $e');
  }

  // ========== INITIALISATION SUPABASE ==========
  // Supabase: Backend pour le stockage des fichiers audio (.m4a)
  await Supabase.initialize(
    url: AppConfig.supabaseUrl, // URL du projet Supabase
    anonKey: AppConfig.supabaseAnonKey, // Clé anonyme pour accès public
  );

  // ========== LANCEMENT DE L'APPLICATION ==========
  // runApp: Lance l'application avec le widget racine MyApp
  runApp(const MyApp());
}

/// MyApp - Widget racine de l'application
/// StatelessWidget: Widget qui ne change pas d'état interne
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// build() - Construit l'interface de l'application
  @override
  Widget build(BuildContext context) {
    // ========== CONFIGURATION DU STATE MANAGEMENT ==========
    // MultiProvider: Fournit plusieurs providers aux widgets enfants
    // Permet à tous les widgets d'accéder aux providers via context
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider: Crée et fournit un provider qui notifie les changements
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ), // Gestion authentification
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        ), // Gestion messagerie
      ],
      // ========== CONFIGURATION DE L'APPLICATION MATERIAL ==========
      // MaterialApp: Widget racine pour une app Material Design
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Masquer le banner "DEBUG"
        title:
            'VoiceUp', // Titre de l'app (affiché dans le gestionnaire de tâches)
        theme: AppTheme.lightTheme, // Thème clair de l'application
        // ========== ÉCRAN D'ACCUEIL DYNAMIQUE ==========
        // home: Écran affiché au démarrage (change selon l'état d'authentification)
        home: Consumer<AuthProvider>(
          // Consumer: Écoute les changements du AuthProvider
          // builder: Fonction appelée quand AuthProvider change
          // authProvider: Instance actuelle du AuthProvider
          builder: (context, authProvider, _) {
            // Logs pour debugging (affichés dans la console)
            print('🔵 Main: Building home screen');
            print('   Status: ${authProvider.status}');
            print('   IsAuthenticated: ${authProvider.isAuthenticated}');
            print('   CurrentUser: ${authProvider.currentUser?.email}');

            // ========== AFFICHAGE SELON L'ÉTAT D'AUTHENTIFICATION ==========

            // 1. Si l'état est "initial": Vérification en cours
            // Afficher un loader pendant la vérification de la session
            if (authProvider.status == AuthStatus.initial) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(), // Cercle de chargement
                ),
              );
            }

            // 2. Si l'utilisateur est authentifié: Afficher la liste des conversations
            // Vérifier à la fois isAuthenticated ET que currentUser n'est pas null
            if (authProvider.isAuthenticated &&
                authProvider.currentUser != null) {
              return const ConversationsListScreen(); // Écran principal
            } else {
              // 3. Sinon: Afficher l'écran de connexion
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
