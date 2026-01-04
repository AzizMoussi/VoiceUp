# VoiceUp - Application de Chat Vocal

Application mobile de messagerie instantanée basée sur les messages vocaux et texte, développée avec Flutter.

---

## Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture du Projet](#architecture-du-projet)
3. [Structure des Dossiers](#structure-des-dossiers)
4. [Flux de Données (Workflows)](#flux-de-données-workflows)
5. [Technologies Utilisées](#technologies-utilisées)
6. [Installation et Configuration](#installation-et-configuration)
7. [Fonctionnalités](#fonctionnalités)
8. [Sécurité](#sécurité)

---

## Vue d'ensemble

VoiceUp est une application de messagerie instantanée qui met l'accent sur la communication vocale. Elle permet aux utilisateurs de :

- S'inscrire et se connecter avec email/mot de passe
- Échanger des messages texte et vocaux en temps réel
- Rechercher d'autres utilisateurs pour démarrer des conversations
- Écouter les messages vocaux avec contrôles de lecture

**Principe technique** : L'application utilise Firebase pour l'authentification et la base de données (Firestore), et Supabase pour le stockage des fichiers audio.

---

## Architecture du Projet

L'application suit le pattern **Clean Architecture** qui sépare le code en 3 couches distinctes :

```
┌─────────────────────────────────────────────┐
│         PRESENTATION LAYER                  │
│    (UI - Ce que l'utilisateur voit)        │
│  • Screens (écrans)                         │
│  • Widgets (composants UI)                  │
│  • Providers (gestion d'état)               │
└──────────────┬──────────────────────────────┘
               │ Appelle les méthodes
               ▼
┌─────────────────────────────────────────────┐
│            DATA LAYER                       │
│    (Logique métier et données)              │
│  • Repositories (logique business)          │
│  • Models (structure des données)           │
└──────────────┬──────────────────────────────┘
               │ Communique avec
               ▼
┌─────────────────────────────────────────────┐
│        EXTERNAL SERVICES                    │
│    (Services externes)                      │
│  • Firebase Auth                            │
│  • Cloud Firestore                          │
│  • Supabase Storage                         │
│  • Native APIs (microphone, file system)    │
└─────────────────────────────────────────────┘
```

### Pourquoi cette architecture ?

1. **Séparation des responsabilités** : Chaque couche a un rôle précis
2. **Testabilité** : Facile de tester chaque couche indépendamment
3. **Maintenabilité** : Modifications isolées sans impacter tout le code
4. **Scalabilité** : Facile d'ajouter de nouvelles fonctionnalités

---

## Structure des Dossiers

```
lib/
├── main.dart                          # Point d'entrée de l'application
│
├── core/                              # Configurations et constantes globales
│   ├── config/
│   │   └── app_config.dart           # Variables d'environnement (.env)
│   ├── constants/
│   │   └── app_constants.dart        # Constantes (couleurs, tailles, etc.)
│   └── theme/
│       └── app_theme.dart            # Thème Material Design 3
│
├── presentation/                      # COUCHE PRÉSENTATION (UI)
│   ├── screens/                      # Écrans de l'application
│   │   ├── auth/
│   │   │   ├── login_screen.dart     # Écran de connexion
│   │   │   └── register_screen.dart  # Écran d'inscription
│   │   ├── conversations/
│   │   │   └── conversations_list_screen.dart  # Liste des conversations
│   │   ├── chat/
│   │   │   └── chat_screen.dart      # Écran de chat (messages)
│   │   ├── search/
│   │   │   └── search_users_screen.dart  # Recherche d'utilisateurs
│   │   └── home/
│   │       └── home_screen.dart      # Navigation principale
│   │
│   └── widgets/                      # Composants UI réutilisables
│       ├── voice_recorder_button.dart     # Bouton d'enregistrement vocal
│       └── voice_message_player.dart      # Lecteur de messages vocaux
│
├── providers/                         # GESTION D'ÉTAT (State Management)
│   ├── auth_provider.dart            # État d'authentification
│   └── chat_provider.dart            # État des conversations/messages
│
├── data/                             # COUCHE DONNÉES
│   ├── models/                       # Modèles de données
│   │   ├── user_model.dart          # Modèle Utilisateur
│   │   ├── message_model.dart       # Modèle Message
│   │   └── conversation_model.dart  # Modèle Conversation
│   │
│   └── repositories/                 # Logique métier et accès aux données
│       ├── auth_repository.dart     # Logique d'authentification
│       └── chat_repository.dart     # Logique de messagerie
│
└── [Services externes]               # COUCHE EXTERNE (pas dans lib/)
    ├── Firebase (cloud)
    ├── Supabase (cloud)
    └── APIs natives (device)
```

### Explication détaillée de chaque fichier clé

#### 1. **main.dart** - Point d'entrée

- Initialise Firebase et Supabase
- Charge les variables d'environnement (.env)
- Configure les Providers (AuthProvider, ChatProvider)
- Lance l'application avec MaterialApp

#### 2. **core/config/app_config.dart** - Configuration

- Lit les clés API depuis le fichier .env
- Fournit les valeurs Firebase et Supabase de manière sécurisée
- Évite de hardcoder les secrets dans le code

#### 3. **providers/auth_provider.dart** - État d'authentification

- Gère l'état de connexion de l'utilisateur (connecté/déconnecté)
- Utilise `ChangeNotifier` pour notifier l'UI des changements
- Appelle `AuthRepository` pour les opérations d'authentification

#### 4. **providers/chat_provider.dart** - État de messagerie

- Gère la liste des conversations
- Gère les messages d'une conversation
- Écoute les mises à jour Firestore en temps réel via Streams
- Notifie l'UI quand de nouveaux messages arrivent

#### 5. **data/repositories/auth_repository.dart** - Logique d'authentification

- `signUp()` : Créer un compte (Firebase Auth + Firestore)
- `signIn()` : Se connecter
- `signOut()` : Se déconnecter
- `getCurrentUser()` : Récupérer l'utilisateur actuel
- Gère les erreurs Firebase

#### 6. **data/repositories/chat_repository.dart** - Logique de messagerie

- `sendTextMessage()` : Envoyer un message texte
- `sendVoiceMessage()` : Upload audio vers Supabase + créer message
- `getConversations()` : Stream des conversations de l'utilisateur
- `getMessages()` : Stream des messages d'une conversation
- `createConversation()` : Créer une nouvelle conversation

#### 7. **data/models/message_model.dart** - Structure d'un message

```dart
{
  id: String,              // ID unique Firestore
  conversationId: String,  // ID de la conversation
  senderId: String,        // ID de l'expéditeur
  receiverId: String,      // ID du destinataire
  content: String,         // Texte du message (vide si vocal)
  audioUrl: String?,       // URL Supabase (si message vocal)
  type: MessageType,       // "text" ou "voice"
  timestamp: DateTime      // Date/heure d'envoi
}
```

#### 8. **presentation/widgets/voice_recorder_button.dart** - Enregistrement audio

- Bouton avec appui long pour enregistrer
- Demande la permission microphone
- Utilise le package `record` pour capturer l'audio
- Sauvegarde en format M4A (AAC)
- Appelle `ChatProvider` pour envoyer le fichier

#### 9. **presentation/widgets/voice_message_player.dart** - Lecture audio

- Affiche la durée du message vocal
- Boutons play/pause
- Barre de progression
- **Mobile** : Télécharge et cache le fichier localement
- **Web** : Streaming direct depuis Supabase
- Utilise le package `audioplayers`

---

## Flux de Données (Workflows)

### 1. Workflow d'Inscription

```
Utilisateur entre email/password
         ↓
[register_screen.dart] Appuie sur "S'inscrire"
         ↓
[auth_provider.dart] signUp(email, password)
         ↓
[auth_repository.dart] signUp()
         ↓
[Firebase Auth] Créer compte → Retourne User
         ↓
[Firestore] Créer document dans collection "users"
         {
           id: user.uid,
           email: email,
           displayName: nom,
           createdAt: now
         }
         ↓
[auth_provider.dart] Met à jour l'état (user connecté)
         ↓
[UI] Navigation automatique vers ConversationsListScreen
```

### 2. Workflow d'Envoi de Message Vocal

```
Utilisateur appuie longuement sur bouton micro
         ↓
[voice_recorder_button.dart]
  1. Demande permission microphone
  2. record.start() → Enregistrement audio
         ↓
Utilisateur relâche le bouton
         ↓
[voice_recorder_button.dart]
  1. record.stop() → Retourne path du fichier
  2. Appelle provider.sendVoiceMessage(file)
         ↓
[chat_provider.dart] sendVoiceMessage()
         ↓
[chat_repository.dart] sendVoiceMessage()
         ↓
[Supabase Storage]
  1. Upload fichier vers bucket "voiceapp"
     Path: "voices/{userId}/{timestamp}.m4a"
  2. Générer URL signée (valide 1 an)
     → Retourne signedUrl
         ↓
[Firestore]
  Créer document dans "conversations/{convId}/messages/"
  {
    id: auto,
    senderId: currentUserId,
    receiverId: otherUserId,
    audioUrl: signedUrl,
    type: "voice",
    timestamp: now
  }
         ↓
[Firestore Stream] Détecte le nouveau message
         ↓
[chat_provider.dart] Met à jour la liste des messages
         ↓
[chat_screen.dart] Rebuild automatique
         ↓
[UI] Nouveau message vocal s'affiche
```

### 3. Workflow de Lecture de Message Vocal

```
Message vocal affiché dans [chat_screen.dart]
         ↓
[voice_message_player.dart] initState()
  1. Reçoit audioUrl (URL Supabase signée)
  2. Appelle _loadAudioFile()
         ↓
**SI MOBILE:**
  1. Vérifie si fichier existe en cache
     Path: /cache/voice_{timestamp}.m4a
  2. SI cache absent:
     - http.get(audioUrl) → Télécharge
     - file.writeAsBytes() → Sauvegarde en cache
  3. audioPlayer.setSourceDeviceFile(localPath)
  4. audioPlayer.getDuration() → Durée réelle
         ↓
**SI WEB:**
  1. audioPlayer.setSourceUrl(audioUrl)
  2. audioPlayer.getDuration() → Durée réelle
         ↓
[UI] Affiche durée (ex: "00:03")
         ↓
Utilisateur appuie sur bouton Play
         ↓
[voice_message_player.dart] _play()
  1. audioPlayer.play()
  2. Écoute audioPlayer.onPositionChanged
  3. Met à jour la barre de progression
         ↓
[UI] Barre de progression se remplit pendant la lecture
```

### 4. Workflow de Synchronisation Temps Réel

```
[chat_screen.dart] initState()
         ↓
[chat_provider.dart] loadMessages(conversationId)
         ↓
[chat_repository.dart] getMessages(conversationId)
         ↓
[Firestore] Crée un Stream sur la collection:
  "conversations/{convId}/messages"
  .orderBy('timestamp', descending: true)
  .snapshots()
         ↓
**Stream actif** : Écoute en continu les changements
         ↓
**ÉVÉNEMENT:** Nouveau message ajouté dans Firestore
  (par l'utilisateur actuel OU par l'autre utilisateur)
         ↓
[Stream] Émet un nouvel événement avec les données
         ↓
[chat_provider.dart] Reçoit l'événement
  1. Parse les documents en MessageModel
  2. Met à jour _messages
  3. notifyListeners()
         ↓
[chat_screen.dart] Rebuild automatique
         ↓
[UI] Nouveau message apparaît instantanément
```

---

## Configuration

### Prérequis

- Flutter SDK 3.24.5+
- Dart 3.5.4+
- Firebase Project
- Supabase Project

### Installation

1. Cloner le repository

```bash
git clone <repository-url>
cd voice_up
```

2. Installer les dépendances

```bash
flutter pub get
```

3. Configurer les variables d'environnement

Copier le fichier `.env.example` en `.env` :

```bash
cp .env.example .env
```

Remplir les valeurs dans `.env` avec vos clés:

```env
# Firebase Configuration
FIREBASE_API_KEY=votre_cle_api_firebase
FIREBASE_PROJECT_ID=votre_project_id
FIREBASE_MESSAGING_SENDER_ID=votre_sender_id
FIREBASE_APP_ID=votre_app_id
FIREBASE_STORAGE_BUCKET=votre_storage_bucket

# Supabase Configuration
SUPABASE_URL=votre_url_supabase
SUPABASE_ANON_KEY=votre_cle_anon_supabase
```

4. Configurer Firebase pour Android

Placer votre fichier `google-services.json` dans :

```
android/app/google-services.json
```

5. Lancer l'application

```bash
flutter run
```

---

## Technologies Utilisées

### Framework Principal

- **Flutter 3.24.5** - Framework UI cross-platform développé par Google

  - Permet de créer des apps Android, iOS, Web avec un seul codebase
  - Utilise le moteur de rendu Skia pour des performances natives
  - Hot Reload pour développement rapide

- **Dart 3.5.4** - Langage de programmation
  - Orienté objet, typage fort
  - Compilation AOT (Ahead-of-Time) pour performance
  - Support async/await pour programmation asynchrone

### Backend et Base de Données

#### Firebase (Google Cloud Platform)

- **Firebase Authentication 5.7.0**

  - Gestion des comptes utilisateurs (email/password)
  - Tokens JWT automatiques pour sécuriser les requêtes
  - Gestion des sessions

- **Cloud Firestore 5.6.12**

  - Base de données NoSQL en temps réel
  - Structure : Collections > Documents > Sous-collections
  - Synchronisation automatique via Streams
  - Requêtes puissantes avec filtres et tri

  **Collections utilisées :**

  ```
  users/                        # Collection des utilisateurs
    {userId}/                   # Document par utilisateur
      - email
      - displayName
      - createdAt

  conversations/                # Collection des conversations
    {conversationId}/           # Document par conversation
      - participants: [userId1, userId2]
      - lastMessage
      - lastMessageTime
      - unreadCount

      messages/                 # Sous-collection des messages
        {messageId}/            # Document par message
          - senderId
          - receiverId
          - content (texte)
          - audioUrl (si vocal)
          - type: "text" | "voice"
          - timestamp
  ```

#### Supabase (Alternative PostgreSQL open-source)

- **Supabase Flutter 2.9.3**

  - Backend-as-a-Service
  - Utilisé uniquement pour **Storage** (stockage de fichiers)
  - Bucket "voiceapp" pour les fichiers audio
  - URLs signées pour sécurité (expiration 1 an)

  **Pourquoi Supabase pour l'audio ?**

  - Firebase Storage est payant au-delà de 5GB
  - Supabase offre 1GB gratuit
  - Performance similaire avec CDN intégré

### State Management

- **Provider 6.1.2**

  - Pattern recommandé par l'équipe Flutter
  - Utilise `ChangeNotifier` pour notifier l'UI des changements
  - Injection de dépendances simple

  **Providers utilisés :**

  - `AuthProvider` : État de connexion (user, isLoading, error)
  - `ChatProvider` : Conversations et messages (conversations, messages, isLoading)

### Audio (Fonctionnalité Principale)

- **Record 5.2.1**
  - Enregistrement audio natif (Android/iOS)
  - Format : M4A avec codec AAC (Audio Advanced Coding)
  - Échantillonnage : 44.1kHz, Stéréo
  - Gestion automatique des permissions microphone
- **Audioplayers 5.2.1**
  - Lecture audio multiplateforme
  - Contrôles : play, pause, stop, seek
  - Événements : onDurationChanged, onPositionChanged, onPlayerComplete
  - Support : URLs distantes, fichiers locaux

### Utilitaires

- **Path Provider 2.1.4**

  - Accès aux répertoires système
  - getTemporaryDirectory() pour cache audio
  - getApplicationDocumentsDirectory() pour données persistantes

- **HTTP 1.2.2**

  - Client HTTP pour télécharger les fichiers audio
  - Utilisé pour cacher les fichiers Supabase localement (mobile)

- **Flutter Dotenv 5.2.1**

  - Charge les variables d'environnement depuis .env
  - Sécurise les clés API (pas hardcodées dans le code)

- **Intl 0.19.0**

  - Formatage des dates et heures
  - Localisation (i18n)
  - Exemple : "Il y a 5 minutes", "14:30"

- **Permission Handler 11.3.1**
  - Gestion des permissions natives (microphone, stockage)
  - Demande automatique à l'utilisateur
  - Vérifie les autorisations

### UI/UX

- **Material Design 3**
  - Design system de Google
  - Thème personnalisé violet
  - Composants : AppBar, FloatingActionButton, Card, etc.

---

## Installation et Configuration

### Étapes d'installation

1. **Cloner le repository**

```bash
git clone <repository-url>
cd voice_up
```

2. **Installer Flutter**

   - Télécharger Flutter SDK : https://flutter.dev/docs/get-started/install
   - Ajouter Flutter au PATH
   - Vérifier : `flutter doctor`

3. **Installer les dépendances**

```bash
flutter pub get
```

4. **Configurer les variables d'environnement**

Copier `.env.example` vers `.env` :

```bash
cp .env.example .env
```

Éditer `.env` avec vos vraies clés :

```env
# Obtenir sur Firebase Console (https://console.firebase.google.com)
FIREBASE_API_KEY=votre_cle_api_firebase
FIREBASE_PROJECT_ID=votre_project_id
FIREBASE_MESSAGING_SENDER_ID=votre_sender_id
FIREBASE_APP_ID=votre_app_id
FIREBASE_STORAGE_BUCKET=votre_storage_bucket

# Obtenir sur Supabase Dashboard (https://app.supabase.com)
SUPABASE_URL=votre_url_supabase
SUPABASE_ANON_KEY=votre_cle_anon_supabase
```

5. **Configurer Firebase pour Android**

   - Télécharger `google-services.json` depuis Firebase Console
   - Placer dans : `android/app/google-services.json`

6. **Configurer Supabase Storage**

   - Créer un bucket nommé "voiceapp"
   - Configurer les politiques RLS (Row Level Security)

7. **Lancer l'application**

```bash
# Android
flutter run

# Web
flutter run -d chrome

# iOS (Mac uniquement)
flutter run -d ios
```

---

## Fonctionnalités

### 1. Authentification

- ✅ Inscription avec email/mot de passe
- ✅ Connexion
- ✅ Déconnexion
- ✅ Gestion de session (auto-login si connecté)
- ✅ Validation des formulaires
- ✅ Gestion des erreurs (email déjà utilisé, mot de passe faible, etc.)

### 2. Liste des Conversations

- ✅ Affichage de toutes les conversations de l'utilisateur
- ✅ Dernier message affiché
- ✅ Horodatage ("Il y a 5 min", "Hier", etc.)
- ✅ Badge avec nombre de messages non lus
- ✅ Mise à jour en temps réel
- ✅ Bouton pour démarrer une nouvelle conversation

### 3. Chat (Messagerie)

- ✅ Envoi de messages texte
- ✅ Enregistrement et envoi de messages vocaux (appui long)
- ✅ Bulles de messages différenciées (envoyé vs reçu)
- ✅ Affichage de l'horodatage de chaque message
- ✅ Synchronisation temps réel (messages apparaissent instantanément)
- ✅ Scroll automatique vers le bas pour nouveaux messages

### 4. Messages Vocaux

- ✅ Enregistrement audio (appui long sur bouton micro)
- ✅ Indicateur visuel pendant l'enregistrement
- ✅ Format M4A/AAC (compression efficace)
- ✅ Upload automatique vers Supabase
- ✅ Lecture avec contrôles play/pause
- ✅ Affichage de la durée (ex: "00:03")
- ✅ Barre de progression pendant la lecture
- ✅ Cache intelligent (mobile) pour éviter téléchargements répétés

### 5. Recherche d'Utilisateurs

- ✅ Recherche par nom ou email
- ✅ Filtrage en temps réel
- ✅ Démarrage de nouvelle conversation en un clic

### 6. Performance et Optimisation

- ✅ Cache audio (mobile) : fichiers téléchargés une seule fois
- ✅ Streams Firestore : synchronisation temps réel efficace
- ✅ Lazy loading des messages (charger par batch si beaucoup)
- ✅ Compression audio (AAC)

---

## Sécurité

### Fichiers à ne JAMAIS commit sur Git

⚠️ **IMPORTANT** : Ces fichiers contiennent des secrets et sont exclus par `.gitignore` :

- `.env` - Clés API Firebase et Supabase
- `android/app/google-services.json` - Configuration Firebase Android
- `ios/Runner/GoogleService-Info.plist` - Configuration Firebase iOS

### Mesures de sécurité implémentées

#### 1. Authentification

- Mots de passe hashés par Firebase (bcrypt)
- Tokens JWT pour les sessions
- Expiration automatique des sessions

#### 2. Base de données Firestore

**Règles de sécurité** :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Seul l'utilisateur peut lire/écrire ses propres données
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    // Seuls les participants peuvent accéder à une conversation
    match /conversations/{conversationId} {
      allow read, write: if request.auth.uid in resource.data.participants;

      // Messages de la conversation
      match /messages/{messageId} {
        allow read, write: if request.auth.uid in
          get(/databases/$(database)/documents/conversations/$(conversationId))
          .data.participants;
      }
    }
  }
}
```

#### 3. Supabase Storage

**Politiques RLS** :

```sql
-- Seuls les utilisateurs authentifiés peuvent uploader
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'voiceapp');

-- Tous peuvent lire (via URLs signées)
CREATE POLICY "Users can read all files"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'voiceapp');
```

#### 4. URLs Audio

- URLs signées (expiration 1 an)
- Pas d'URLs publiques permanentes
- Régénération automatique si expirées

#### 5. Communication

- Toutes les requêtes en HTTPS
- Pas de données sensibles en clair
- Validation des entrées utilisateur

---

## Concepts Clés pour l'Examen

### 1. Clean Architecture

**Question possible** : "Expliquez l'architecture de votre application"

**Réponse** :

- **Couche Présentation** : Widgets et écrans (UI). Affiche les données et capture les actions utilisateur
- **Couche Données** : Repositories et modèles. Contient la logique métier et structure les données
- **Couche Externe** : Firebase, Supabase, APIs natives. Services externes

**Avantages** :

- Séparation des responsabilités → code plus clair
- Testabilité → chaque couche testable indépendamment
- Maintenabilité → changements isolés

### 2. State Management avec Provider

**Question possible** : "Comment gérez-vous l'état de l'application ?"

**Réponse** :

- Utilise le pattern **Provider** (recommandé par Flutter)
- `ChangeNotifier` : Notifie l'UI quand les données changent
- `notifyListeners()` : Déclenche un rebuild des widgets qui écoutent
- Exemple : Quand un nouveau message arrive, `ChatProvider` appelle `notifyListeners()`, et `ChatScreen` se rebuild automatiquement

### 3. Temps Réel avec Firestore Streams

**Question possible** : "Comment fonctionne la synchronisation temps réel ?"

**Réponse** :

- Firestore propose des **Streams** (flux de données continus)
- `.snapshots()` : Écoute les changements dans une collection
- Dès qu'un document est ajouté/modifié/supprimé, le Stream émet un événement
- Le Provider reçoit l'événement et met à jour l'UI automatiquement
- **Aucun polling** (pas de requêtes répétées) → efficace

### 4. Upload Audio (Workflow Complet)

**Question possible** : "Expliquez le processus d'envoi d'un message vocal"

**Réponse** :

1. Utilisateur appuie longuement → Permission microphone
2. `record.start()` → Enregistrement audio
3. Utilisateur relâche → `record.stop()` → Fichier M4A sauvegardé
4. Upload vers Supabase Storage → Retourne URL signée
5. Création d'un document Firestore avec `audioUrl`
6. Stream Firestore détecte le nouveau message
7. UI se met à jour automatiquement

### 5. Cache Audio (Optimisation)

**Question possible** : "Comment optimisez-vous les performances pour les messages vocaux ?"

**Réponse** :

- **Problème** : Retélécharger le même fichier à chaque fois = gaspillage bande passante
- **Solution** : Cache local (mobile)
  1. Vérifier si fichier existe en cache (`/cache/voice_*.m4a`)
  2. Si absent : télécharger via HTTP et sauvegarder
  3. Si présent : utiliser directement
- **Résultat** : Fichier téléchargé une seule fois, lectures suivantes instantanées

### 6. Différence Firebase vs Supabase

**Question possible** : "Pourquoi utilisez-vous deux backends ?"

**Réponse** :

- **Firebase** : Authentification + Base de données
  - Excellente intégration avec Flutter
  - Firestore parfait pour données structurées et temps réel
  - Authentication robuste et sécurisée
- **Supabase** : Stockage de fichiers uniquement
  - Firebase Storage payant après 5GB
  - Supabase gratuit jusqu'à 1GB
  - Performance similaire avec CDN

### 7. Format Audio M4A/AAC

**Question possible** : "Pourquoi le format M4A ?"

**Réponse** :

- **AAC (Advanced Audio Coding)** : Codec moderne
- Meilleure compression que MP3 (fichiers plus petits)
- Qualité audio excellente même compressé
- Support natif Android/iOS/Web
- Ratio qualité/taille optimal pour messagerie

---

## Diagrammes Utiles

### Diagramme de Séquence : Envoi Message Vocal

```
Utilisateur    VoiceRecorder    ChatProvider    ChatRepository    Supabase    Firestore
    |                |                |                |              |           |
    |--Appui long--->|                |                |              |           |
    |                |--Permission--->|                |              |           |
    |                |<--Accordée-----|                |              |           |
    |                |--start()--->[Record API]        |              |           |
    |                |                |                |              |           |
    |--Relâche------>|                |                |              |           |
    |                |--stop()---->[Record API]        |              |           |
    |                |<--file.m4a----|                |              |           |
    |                |--sendVoiceMsg->|                |              |           |
    |                |                |--sendVoiceMsg->|              |           |
    |                |                |                |--upload----->|           |
    |                |                |                |<--signedUrl--|           |
    |                |                |                |--createMsg---------->    |
    |                |                |                |              |    <--docId
    |                |                |<--success------|              |           |
    |                |<--success------|                |              |           |
    |<--Affichage----|                |                |              |           |
    |                |                |                |              |           |
    |                |          [Stream détecte nouveau message]      |           |
    |                |                |<---------onChange------------------------|
    |<--UI update----|<--notifyListeners()                           |           |
```

### Schéma Firestore

```
users/
  user1/
    - email: "alice@example.com"
    - displayName: "Alice"
    - createdAt: 2026-01-01T10:00:00Z

  user2/
    - email: "bob@example.com"
    - displayName: "Bob"
    - createdAt: 2026-01-01T11:00:00Z

conversations/
  conv1/
    - participants: ["user1", "user2"]
    - lastMessage: "Salut !"
    - lastMessageTime: 2026-01-04T14:30:00Z
    - unreadCount: {user1: 0, user2: 1}

    messages/
      msg1/
        - senderId: "user1"
        - receiverId: "user2"
        - type: "text"
        - content: "Salut !"
        - timestamp: 2026-01-04T14:30:00Z

      msg2/
        - senderId: "user2"
        - receiverId: "user1"
        - type: "voice"
        - audioUrl: "https://supabase.co/storage/...signed..."
        - timestamp: 2026-01-04T14:32:00Z
```

---

## Commandes Utiles

```bash
# Lancer l'app en mode debug
flutter run

# Lancer sur web
flutter run -d chrome

# Build pour production Android
flutter build apk --release

# Build pour production Web
flutter build web

# Nettoyer les fichiers de build
flutter clean

# Mettre à jour les dépendances
flutter pub upgrade

# Analyser le code
flutter analyze

# Formatter le code
flutter format lib/

# Voir les devices connectés
flutter devices
```

---

## Rapport Technique Complet

Pour une documentation encore plus détaillée incluant les besoins fonctionnels/non-fonctionnels et l'analyse complète, consultez [Rapport.md](Rapport.md).

---

## Questions Fréquentes (FAQ)

**Q: Pourquoi Provider plutôt que Riverpod/Bloc ?**  
R: Provider est plus simple, recommandé officiellement par Flutter, et suffisant pour ce projet.

**Q: Les messages vocaux sont-ils compressés ?**  
R: Oui, le codec AAC compresse automatiquement (qualité proche MP3 mais fichiers plus petits).

**Q: Peut-on ajouter des groupes ?**  
R: Oui, il faudrait modifier le modèle Conversation pour supporter plus de 2 participants.

**Q: Les messages sont-ils chiffrés end-to-end ?**  
R: Non, ils sont chiffrés en transit (HTTPS) et au repos (Firebase/Supabase), mais pas end-to-end.

**Q: Pourquoi M4A et pas MP3 ?**  
R: M4A (AAC) offre une meilleure compression et est natif sur mobile (pas de décodeur externe).

---

**Auteur** : VoiceUp Team  
**Date** : Janvier 2026  
**Version** : 1.0.0
