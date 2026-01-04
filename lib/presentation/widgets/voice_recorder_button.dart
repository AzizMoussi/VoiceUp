// Import des packages nécessaires
import 'package:flutter/material.dart'; // Widgets Flutter
import 'package:flutter/foundation.dart'
    show kIsWeb; // Détection plateforme web
import 'package:record/record.dart'; // Package pour enregistrer l'audio
import 'package:path_provider/path_provider.dart'; // Accès aux répertoires système

/// VoiceRecorderButton - Widget bouton pour enregistrer des messages vocaux
/// Fonctionnement: Appui long pour démarrer, relâcher pour arrêter
class VoiceRecorderButton extends StatefulWidget {
  // Callback appelé quand l'enregistrement est terminé
  // Retourne le chemin du fichier audio enregistré
  final Function(String audioPath) onRecordingComplete;

  const VoiceRecorderButton({super.key, required this.onRecordingComplete});

  @override
  State<VoiceRecorderButton> createState() => _VoiceRecorderButtonState();
}

/// State du bouton d'enregistrement
class _VoiceRecorderButtonState extends State<VoiceRecorderButton> {
  // AudioRecorder: Instance pour gérer l'enregistrement audio
  final AudioRecorder _audioRecorder = AudioRecorder();

  // État de l'enregistrement (en cours ou non)
  bool _isRecording = false;

  // Durée de l'enregistrement en secondes
  int _recordDuration = 0;

  /// dispose() - Libérer les ressources quand le widget est détruit
  @override
  void dispose() {
    _audioRecorder.dispose(); // Libérer l'enregistreur audio
    super.dispose();
  }

  /// _startRecording() - Démarre l'enregistrement audio
  Future<void> _startRecording() async {
    try {
      // ========== VÉRIFICATION PLATEFORME WEB ==========
      // kIsWeb: Constant qui est true sur navigateur web
      if (kIsWeb) {
        // Afficher un message d'avertissement sur web
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Les messages vocaux ne sont pas encore supportés sur le web. '
                'Veuillez utiliser l\'application mobile.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return; // Sortir de la fonction
      }

      // ========== VÉRIFICATION PERMISSION MICROPHONE ==========
      // hasPermission(): Vérifie si l'app a la permission d'utiliser le micro
      if (await _audioRecorder.hasPermission()) {
        String filePath;

        if (kIsWeb) {
          // Sur web: Chemin simple (géré en interne par le package)
          filePath = 'voice_${DateTime.now().millisecondsSinceEpoch}';
        } else {
          // ========== SUR MOBILE: CRÉER LE CHEMIN COMPLET ==========
          // getTemporaryDirectory(): Retourne le répertoire temporaire
          final directory = await getTemporaryDirectory();
          // Créer un nom unique avec timestamp
          filePath =
              '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        }

        // ========== DÉMARRER L'ENREGISTREMENT ==========
        await _audioRecorder.start(
          // RecordConfig: Configuration de l'enregistrement
          const RecordConfig(
            encoder: AudioEncoder.aacLc, // Codec AAC (compression efficace)
          ),
          path: filePath, // Chemin où sauvegarder le fichier
        );

        // Mettre à jour l'interface
        setState(() {
          _isRecording = true; // En cours d'enregistrement
          _recordDuration = 0; // Réinitialiser la durée
        });

        // ========== BOUCLE POUR COMPTER LES SECONDES ==========
        // Met à jour le compteur chaque seconde pendant l'enregistrement
        while (_isRecording) {
          await Future.delayed(
            const Duration(seconds: 1),
          ); // Attendre 1 seconde
          if (_isRecording) {
            setState(() {
              _recordDuration++; // Incrémenter la durée
            });
          }
        }
      } else {
        // Permission refusée
        print('🔴 Microphone permission denied');
      }
    } catch (e) {
      // Gestion des erreurs
      print('🔴 Error starting recording: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  /// _stopRecording() - Arrête l'enregistrement et récupère le fichier
  Future<void> _stopRecording() async {
    try {
      // stop(): Arrête l'enregistrement et retourne le chemin du fichier
      final path = await _audioRecorder.stop();

      // Mettre à jour l'interface
      setState(() {
        _isRecording = false; // Arrêter l'enregistrement
        _recordDuration = 0; // Réinitialiser la durée
      });

      // ========== VÉRIFIER QUE LE FICHIER EXISTE ==========
      if (path != null) {
        print('🟢 Recording saved at: $path');
        // Appeler le callback avec le chemin du fichier
        widget.onRecordingComplete(path);
      } else {
        print('🔴 Recording path is null');
      }
    } catch (e) {
      print('🔴 Error stopping recording: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  /// _formatDuration() - Formater la durée en MM:SS
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60; // Division entière pour les minutes
    final secs = seconds % 60; // Modulo pour les secondes
    // padLeft(2, '0'): Ajouter un 0 devant si < 10 (ex: 5 → 05)
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// build() - Construit l'interface du bouton
  @override
  Widget build(BuildContext context) {
    // ========== GESTURE DETECTOR ==========
    // GestureDetector: Détecte les gestes de l'utilisateur
    return GestureDetector(
      // onLongPressStart: Appelé quand l'utilisateur appuie longuement
      onLongPressStart: (_) => _startRecording(),
      // onLongPressEnd: Appelé quand l'utilisateur relâche
      onLongPressEnd: (_) => _stopRecording(),

      // ========== CONTAINER DU BOUTON ==========
      // Container: Boîte avec décoration (couleur, forme, bordures)
      child: Container(
        padding: const EdgeInsets.all(12), // Espacement interne
        // BoxDecoration: Définir l'apparence du container
        decoration: BoxDecoration(
          // Couleur change selon l'état: rouge si enregistre, violet sinon
          color: _isRecording ? Colors.red : const Color(0xFF6C63FF),
          shape: BoxShape.circle, // Forme circulaire
        ),
        // ========== CONTENU DU BOUTON ==========
        child: _isRecording
            // Si enregistrement en cours: Afficher icône + compteur
            ? Column(
                // Column: Dispose verticalement
                mainAxisSize: MainAxisSize.min, // Prendre le minimum de place
                children: [
                  // Icône microphone
                  const Icon(Icons.mic, color: Colors.white, size: 24),
                  const SizedBox(height: 4), // Espace vertical
                  // Compteur de durée (00:05, 00:12, etc.)
                  Text(
                    _formatDuration(_recordDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            // Sinon: Afficher seulement l'icône microphone
            : const Icon(Icons.mic, color: Colors.white, size: 24),
      ),
    );
  }
}
