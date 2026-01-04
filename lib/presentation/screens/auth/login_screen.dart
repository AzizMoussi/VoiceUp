// Import Flutter Material Design components (widgets, themes, etc.)
import 'package:flutter/material.dart';
// Import Provider package for state management
import 'package:provider/provider.dart';
// Import AuthProvider to handle authentication logic
import '../../../providers/auth_provider.dart';
// Import app constants (error messages, text labels)
import '../../../core/constants/app_constants.dart';
// Import SignUpScreen for navigation
import 'signup_screen.dart';

/// LoginScreen - Écran de connexion de l'application
/// StatefulWidget: Widget qui peut changer d'état (ex: afficher un loader)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// State class pour LoginScreen - Contient la logique et l'état de l'écran
class _LoginScreenState extends State<LoginScreen> {
  // GlobalKey: Clé unique pour identifier et valider le formulaire
  final _formKey = GlobalKey<FormState>();

  // TextEditingController: Contrôleur pour récupérer le texte saisi dans un champ
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // bool: Variable pour afficher/masquer le mot de passe
  // bool: Variable pour afficher/masquer le mot de passe
  bool _obscurePassword = true;

  /// dispose() - Méthode appelée quand le widget est détruit
  /// Libère la mémoire utilisée par les contrôleurs pour éviter les fuites mémoire
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// _handleLogin() - Fonction asynchrone pour gérer la connexion
  /// Valide le formulaire puis appelle AuthProvider pour se connecter
  Future<void> _handleLogin() async {
    // Valider le formulaire (vérifie que tous les validators retournent null)
    if (_formKey.currentState!.validate()) {
      // Récupérer AuthProvider sans écouter les changements (listen: false)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Appeler la méthode signIn du provider (opération asynchrone)
      final success = await authProvider.signIn(
        email: _emailController.text.trim(), // trim() enlève les espaces
        password: _passwordController.text,
      );

      // Vérifier que le widget est toujours monté avant d'utiliser context
      if (!mounted) return;

      // Afficher un message de succès ou d'erreur
      if (success) {
        // ScaffoldMessenger: Affiche un SnackBar (notification temporaire)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.loginSuccess),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? AppConstants.authError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// build() - Construit l'interface utilisateur du widget
  /// Appelée automatiquement quand l'état change (setState)
  @override
  Widget build(BuildContext context) {
    // Consumer ou Provider.of: Écoute les changements de AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    // Scaffold: Structure de base d'une page Material Design
    // Fournit: AppBar, body, floatingActionButton, drawer, etc.
    return Scaffold(
      // body: Contenu principal de la page
      body: SafeArea(
        // SafeArea: Évite le contenu sous la barre de statut/navigation
        child: Center(
          // Center: Centre son enfant horizontalement et verticalement
          child: SingleChildScrollView(
            // Permet de scroller si le contenu dépasse l'écran
            padding: const EdgeInsets.all(
              24.0,
            ), // Espacement interne de 24 pixels
            child: Form(
              // Form: Widget qui contient des champs de formulaire (TextFormField)
              key: _formKey, // Clé pour identifier et valider le formulaire
              child: Column(
                // Column: Dispose ses enfants verticalement
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centrer verticalement
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Étirer horizontalement
                children: [
                  // ========== LOGO ==========
                  // Icon: Widget pour afficher une icône Material
                  const Icon(
                    Icons.mic, // Icône de microphone
                    size: 80, // Taille de l'icône en pixels
                    color: Color(
                      0xFF6C63FF,
                    ), // Couleur violet (format hexadécimal)
                  ),
                  // SizedBox: Widget invisible pour créer un espace
                  const SizedBox(height: 16),

                  // ========== TITRE ==========
                  // Text: Widget pour afficher du texte
                  Text(
                    'VoiceUp', // Texte à afficher
                    // style: Style du texte (police, taille, couleur, etc.)
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold, // Texte en gras
                      color: const Color(0xFF6C63FF), // Couleur violet
                    ),
                    textAlign: TextAlign.center, // Centrer le texte
                  ),
                  const SizedBox(height: 8),

                  // ========== SOUS-TITRE ==========
                  Text(
                    'Connectez-vous pour commencer',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // ========== CHAMP EMAIL ==========
                  // TextFormField: Champ de texte avec validation intégrée
                  TextFormField(
                    controller:
                        _emailController, // Contrôleur pour récupérer le texte
                    keyboardType:
                        TextInputType.emailAddress, // Clavier adapté pour email
                    // decoration: Apparence du champ (label, icônes, bordures)
                    decoration: const InputDecoration(
                      labelText: 'Email', // Label qui flotte au-dessus du champ
                      prefixIcon: Icon(Icons.email_outlined), // Icône à gauche
                    ),
                    // validator: Fonction pour valider la saisie
                    // Retourne null si valide, ou un message d'erreur sinon
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppConstants.emailRequired; // "Email requis"
                      }
                      if (!value.contains('@')) {
                        return AppConstants.emailInvalid; // "Email invalide"
                      }
                      return null; // Valide
                    },
                  ),
                  const SizedBox(height: 16),

                  // ========== CHAMP MOT DE PASSE ==========
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword, // Masquer le texte (••••••)
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      // suffixIcon: Icône à droite du champ
                      suffixIcon: IconButton(
                        // IconButton: Bouton avec seulement une icône
                        icon: Icon(
                          // Afficher icône différente selon l'état
                          _obscurePassword
                              ? Icons
                                    .visibility_off // Œil barré
                              : Icons.visibility, // Œil ouvert
                        ),
                        // onPressed: Fonction appelée au clic
                        onPressed: () {
                          setState(() {
                            // setState: Met à jour l'interface
                            _obscurePassword =
                                !_obscurePassword; // Inverser l'état
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppConstants.passwordRequired;
                      }
                      if (value.length < 6) {
                        return AppConstants.passwordTooShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ========== BOUTON DE CONNEXION ==========
                  // SizedBox: Définir une taille fixe
                  SizedBox(
                    height: 50,
                    // ElevatedButton: Bouton Material avec élévation (ombre)
                    child: ElevatedButton(
                      // onPressed: Fonction appelée au clic (null = bouton désactivé)
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      // child: Contenu du bouton
                      child: authProvider.isLoading
                          // Si chargement: afficher un loader
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              // CircularProgressIndicator: Cercle de chargement animé
                              child: CircularProgressIndicator(
                                strokeWidth: 2, // Épaisseur du cercle
                                // valueColor: Couleur du cercle
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          // Sinon: afficher le texte du bouton
                          : const Text('Se connecter'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ========== LIEN INSCRIPTION ==========
                  // Row: Dispose ses enfants horizontalement
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centrer horizontalement
                    children: [
                      Text(
                        'Pas encore de compte ? ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      // TextButton: Bouton plat sans fond
                      TextButton(
                        onPressed: () {
                          // Navigator: Gère la navigation entre les écrans
                          // push: Ajoute un nouvel écran sur la pile
                          Navigator.of(context).push(
                            // MaterialPageRoute: Transition animée entre les pages
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'S\'inscrire',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
