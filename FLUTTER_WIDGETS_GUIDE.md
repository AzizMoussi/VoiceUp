# Guide des Widgets Flutter - VoiceUp

Ce document explique tous les widgets et composants Flutter utilisés dans l'application VoiceUp.

---

## Widgets de Structure

### 1. **Scaffold**

```dart
Scaffold(
  appBar: AppBar(),     // Barre supérieure
  body: Widget(),       // Contenu principal
  floatingActionButton: FloatingActionButton(), // Bouton flottant
  drawer: Drawer(),     // Menu latéral
  bottomNavigationBar: BottomNavigationBar(), // Barre de navigation
)
```

- **Rôle**: Structure de base d'une page Material Design
- **Fournit**: AppBar, body, drawer, bottom navigation, floating button
- **Exemple**: Chaque écran (LoginScreen, ChatScreen, etc.)

### 2. **SafeArea**

```dart
SafeArea(
  child: Widget(),
)
```

- **Rôle**: Évite que le contenu soit masqué par la barre de statut ou les encoches
- **Utilisation**: Entourer le contenu principal du body
- **Exemple**: `SafeArea(child: Center(...))`

### 3. **Container**

```dart
Container(
  width: 100,
  height: 100,
  padding: EdgeInsets.all(10),
  margin: EdgeInsets.all(5),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(10),
  ),
  child: Widget(),
)
```

- **Rôle**: Boîte avec dimensions, couleurs, bordures, padding
- **Propriétés clés**:
  - `padding`: Espacement interne
  - `margin`: Espacement externe
  - `decoration`: Apparence (couleur, forme, ombre)
  - `alignment`: Position de l'enfant
- **Exemple**: Bouton d'enregistrement vocal (cercle rouge/violet)

---

## Widgets de Disposition (Layout)

### 4. **Column**

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,  // Axe vertical
  crossAxisAlignment: CrossAxisAlignment.start, // Axe horizontal
  children: [
    Widget1(),
    Widget2(),
    Widget3(),
  ],
)
```

- **Rôle**: Dispose ses enfants verticalement (de haut en bas)
- **Propriétés**:
  - `mainAxisAlignment`: Alignement vertical (start, center, end, spaceBetween)
  - `crossAxisAlignment`: Alignement horizontal (start, center, end, stretch)
  - `mainAxisSize`: Taille de la colonne (min ou max)

### 5. **Row**

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Widget1(),
    Widget2(),
  ],
)
```

- **Rôle**: Dispose ses enfants horizontalement (de gauche à droite)
- **Similaire à Column** mais horizontal

### 6. **Center**

```dart
Center(
  child: Widget(),
)
```

- **Rôle**: Centre son enfant horizontalement et verticalement
- **Exemple**: `Center(child: Text('Bonjour'))`

### 7. **SizedBox**

```dart
SizedBox(
  width: 100,
  height: 50,
  child: Widget(),
)
```

- **Rôle**: Définir une taille fixe OU créer un espace vide
- **Utilisations**:
  - Espacement: `SizedBox(height: 16)` (espace vertical de 16px)
  - Taille fixe: `SizedBox(height: 50, child: ElevatedButton(...))`

### 8. **Expanded / Flexible**

```dart
Row(
  children: [
    Expanded(
      flex: 2,
      child: Widget1(), // Prend 2/3 de l'espace
    ),
    Expanded(
      flex: 1,
      child: Widget2(), // Prend 1/3 de l'espace
    ),
  ],
)
```

- **Rôle**: Étirer un widget pour remplir l'espace disponible
- **flex**: Proportion de l'espace (par défaut 1)
- **Exemple**: Champ de texte qui prend tout l'espace restant

---

## Widgets de Défilement

### 9. **SingleChildScrollView**

```dart
SingleChildScrollView(
  padding: EdgeInsets.all(24),
  child: Column(...),
)
```

- **Rôle**: Rendre un widget scrollable (un seul enfant)
- **Utilisation**: Quand le contenu peut dépasser la taille de l'écran
- **Exemple**: Écran de connexion (formulaire)

### 10. **ListView**

```dart
ListView(
  children: [
    ListTile(...),
    ListTile(...),
  ],
)

// Ou avec builder pour grandes listes
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)
```

- **Rôle**: Liste scrollable optimisée
- **builder**: Crée les items à la demande (lazy loading)
- **Exemple**: Liste des conversations

### 11. **ScrollController**

```dart
final _scrollController = ScrollController();

ListView(
  controller: _scrollController,
  children: [...],
)

// Scroller vers le bas programmatiquement
_scrollController.animateTo(
  0,
  duration: Duration(milliseconds: 300),
  curve: Curves.easeOut,
);
```

- **Rôle**: Contrôler le scroll programmatiquement
- **Exemple**: Scroller automatiquement vers le bas quand nouveau message

---

## Widgets de Formulaire

### 12. **Form**

```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(...),
      TextFormField(...),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Formulaire valide
          }
        },
      ),
    ],
  ),
)
```

- **Rôle**: Groupe de champs avec validation centralisée
- **GlobalKey**: Identifiant unique pour accéder au formulaire
- **validate()**: Appelle tous les validators des TextFormField

### 13. **TextFormField**

```dart
TextFormField(
  controller: _controller,
  keyboardType: TextInputType.emailAddress,
  obscureText: true,  // Masquer le texte (mot de passe)
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'exemple@email.com',
    prefixIcon: Icon(Icons.email),
    suffixIcon: Icon(Icons.visibility),
    border: OutlineInputBorder(),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Champ requis';
    }
    return null; // Valide
  },
  onChanged: (value) {
    // Appelé à chaque changement
  },
)
```

- **Rôle**: Champ de texte avec validation
- **Propriétés importantes**:
  - `controller`: Récupérer/modifier le texte
  - `keyboardType`: Type de clavier (email, phone, number)
  - `obscureText`: Masquer (pour mots de passe)
  - `decoration`: Apparence (label, icônes, bordures)
  - `validator`: Fonction de validation
- **Exemple**: Champs email et mot de passe

### 14. **TextEditingController**

```dart
final _controller = TextEditingController();

// Récupérer le texte
String text = _controller.text;

// Modifier le texte
_controller.text = "Nouveau texte";

// Effacer
_controller.clear();

// Libérer la mémoire
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

- **Rôle**: Contrôler le contenu d'un TextFormField
- **Important**: Toujours appeler `dispose()` pour éviter les fuites mémoire

---

## Widgets de Boutons

### 15. **ElevatedButton**

```dart
ElevatedButton(
  onPressed: () {
    // Action au clic
  },
  child: Text('Cliquer'),
)
```

- **Rôle**: Bouton avec élévation (ombre)
- **onPressed**: Fonction appelée au clic (null = désactivé)
- **Exemple**: Bouton "Se connecter"

### 16. **TextButton**

```dart
TextButton(
  onPressed: () {},
  child: Text('Lien'),
)
```

- **Rôle**: Bouton plat sans fond (comme un lien)
- **Exemple**: "S'inscrire", "Mot de passe oublié"

### 17. **IconButton**

```dart
IconButton(
  icon: Icon(Icons.visibility),
  onPressed: () {},
)
```

- **Rôle**: Bouton avec seulement une icône
- **Exemple**: Bouton pour afficher/masquer le mot de passe

### 18. **FloatingActionButton**

```dart
FloatingActionButton(
  onPressed: () {},
  child: Icon(Icons.add),
)
```

- **Rôle**: Bouton flottant circulaire (action principale)
- **Position**: En bas à droite par défaut
- **Exemple**: Bouton pour nouvelle conversation

### 19. **GestureDetector**

```dart
GestureDetector(
  onTap: () {},
  onLongPress: () {},
  onLongPressStart: (_) {},
  onLongPressEnd: (_) {},
  onDoubleTap: () {},
  child: Container(...),
)
```

- **Rôle**: Détecter les gestes sur n'importe quel widget
- **Gestes**:
  - `onTap`: Appui simple
  - `onLongPress`: Appui long
  - `onDoubleTap`: Double appui
  - `onPanUpdate`: Glissement
- **Exemple**: Bouton d'enregistrement vocal (appui long)

---

## Widgets de Texte et Icônes

### 20. **Text**

```dart
Text(
  'Bonjour',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
    decoration: TextDecoration.underline,
  ),
  textAlign: TextAlign.center,
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
)
```

- **Rôle**: Afficher du texte
- **Propriétés**:
  - `style`: Police, taille, couleur, gras, italique
  - `textAlign`: Alignement (left, center, right, justify)
  - `overflow`: Comportement si texte trop long
  - `maxLines`: Nombre maximum de lignes

### 21. **Icon**

```dart
Icon(
  Icons.home,
  size: 30,
  color: Colors.red,
)
```

- **Rôle**: Afficher une icône Material
- **Icons.xxx**: Bibliothèque d'icônes intégrée
- **Exemple**: Icons.mic, Icons.send, Icons.person

---

## Widgets de Navigation

### 22. **AppBar**

```dart
AppBar(
  title: Text('Titre'),
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => Navigator.of(context).pop(),
  ),
  actions: [
    IconButton(icon: Icon(Icons.search), onPressed: () {}),
    IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
  ],
)
```

- **Rôle**: Barre supérieure de l'application
- **Propriétés**:
  - `title`: Titre affiché
  - `leading`: Widget à gauche (souvent bouton retour)
  - `actions`: Liste de widgets à droite (boutons d'action)
  - `backgroundColor`: Couleur de fond

### 23. **Navigator**

```dart
// Aller vers un nouvel écran
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => NewScreen(),
  ),
);

// Retourner à l'écran précédent
Navigator.of(context).pop();

// Remplacer l'écran actuel
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (context) => NewScreen()),
);
```

- **Rôle**: Gérer la navigation entre les écrans
- **push**: Ajouter un écran sur la pile
- **pop**: Retirer l'écran actuel et revenir au précédent
- **pushReplacement**: Remplacer l'écran actuel

---

## Widgets de Feedback

### 24. **CircularProgressIndicator**

```dart
CircularProgressIndicator(
  strokeWidth: 2,
  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
)
```

- **Rôle**: Cercle de chargement animé
- **Exemple**: Afficher pendant le chargement

### 25. **LinearProgressIndicator**

```dart
LinearProgressIndicator(
  value: 0.7, // 70%
  backgroundColor: Colors.grey,
  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
)
```

- **Rôle**: Barre de progression horizontale
- **value**: Pourcentage (0.0 à 1.0)
- **Exemple**: Progression de lecture audio

### 26. **SnackBar**

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Message'),
    duration: Duration(seconds: 3),
    backgroundColor: Colors.green,
    action: SnackBarAction(
      label: 'Annuler',
      onPressed: () {},
    ),
  ),
);
```

- **Rôle**: Notification temporaire en bas de l'écran
- **Exemple**: "Connexion réussie", "Erreur lors de l'envoi"

---

## Widgets d'État (Provider)

### 27. **ChangeNotifierProvider**

```dart
ChangeNotifierProvider(
  create: (_) => AuthProvider(),
  child: MyApp(),
)
```

- **Rôle**: Fournit un provider aux widgets enfants
- **create**: Fonction qui crée l'instance du provider

### 28. **Consumer**

```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return Text('User: ${authProvider.currentUser?.email}');
  },
)
```

- **Rôle**: Écoute les changements d'un provider et rebuild
- **builder**: Fonction appelée quand le provider notifie un changement

### 29. **Provider.of**

```dart
// Écouter les changements (rebuild quand le provider change)
final authProvider = Provider.of<AuthProvider>(context);

// Sans écouter (pas de rebuild, juste appeler une méthode)
final authProvider = Provider.of<AuthProvider>(context, listen: false);
```

- **Rôle**: Accéder à un provider depuis le context
- **listen**: true = rebuild quand changement, false = juste accès

---

## Widgets de Cartes et Listes

### 30. **Card**

```dart
Card(
  elevation: 4, // Hauteur de l'ombre
  margin: EdgeInsets.all(10),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Contenu'),
  ),
)
```

- **Rôle**: Carte Material avec élévation
- **elevation**: Hauteur de l'ombre (0-24)
- **Exemple**: Carte de conversation dans la liste

### 31. **ListTile**

```dart
ListTile(
  leading: CircleAvatar(child: Icon(Icons.person)),
  title: Text('Titre'),
  subtitle: Text('Sous-titre'),
  trailing: Icon(Icons.arrow_forward),
  onTap: () {},
)
```

- **Rôle**: Élément de liste Material Design standard
- **Propriétés**:
  - `leading`: Widget à gauche (souvent avatar)
  - `title`: Titre principal
  - `subtitle`: Texte secondaire
  - `trailing`: Widget à droite (souvent icône)
  - `onTap`: Action au clic

---

## Widgets Avancés

### 32. **StreamBuilder**

```dart
StreamBuilder<List<Message>>(
  stream: messagesStream,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Erreur: ${snapshot.error}');
    }
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Text('Aucun message');
    }

    final messages = snapshot.data!;
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return MessageWidget(message: messages[index]);
      },
    );
  },
)
```

- **Rôle**: Écoute un Stream et rebuild automatiquement
- **stream**: Source de données en temps réel (Firestore)
- **snapshot**: État actuel du stream (données, erreur, loading)
- **Exemple**: Liste de messages temps réel

### 33. **FutureBuilder**

```dart
FutureBuilder<User>(
  future: fetchUser(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Erreur');
    }
    return Text('User: ${snapshot.data?.name}');
  },
)
```

- **Rôle**: Exécute une Future et rebuild quand terminée
- **future**: Opération asynchrone (API call, database query)

---

## Widgets de Décoration

### 34. **BoxDecoration**

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.black, width: 2),
    boxShadow: [
      BoxShadow(
        color: Colors.grey,
        blurRadius: 5,
        offset: Offset(0, 3),
      ),
    ],
    gradient: LinearGradient(
      colors: [Colors.blue, Colors.purple],
    ),
  ),
)
```

- **Rôle**: Décoration pour Container
- **Propriétés**:
  - `color`: Couleur de fond
  - `borderRadius`: Coins arrondis
  - `border`: Bordure
  - `boxShadow`: Ombre
  - `gradient`: Dégradé de couleurs

### 35. **ClipRRect**

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Image.network('url'),
)
```

- **Rôle**: Découper un widget avec des coins arrondis
- **Exemple**: Image avec coins arrondis

---

## Widgets Utiles

### 36. **Spacer**

```dart
Row(
  children: [
    Text('Gauche'),
    Spacer(), // Prend tout l'espace disponible
    Text('Droite'),
  ],
)
```

- **Rôle**: Espace flexible qui remplit l'espace disponible
- **Équivalent**: `Expanded(child: SizedBox())`

### 37. **Divider**

```dart
Divider(
  color: Colors.grey,
  thickness: 1,
  indent: 16,
  endIndent: 16,
)
```

- **Rôle**: Ligne horizontale de séparation
- **Exemple**: Séparer les éléments de liste

### 38. **Padding**

```dart
Padding(
  padding: EdgeInsets.all(16),
  child: Text('Texte avec padding'),
)
```

- **Rôle**: Ajouter un espacement autour d'un widget
- **EdgeInsets**:
  - `all(16)`: 16px de tous les côtés
  - `symmetric(horizontal: 16, vertical: 8)`: Horizontal et vertical
  - `only(left: 16, top: 8)`: Spécifique

---

## Résumé des Widgets par Catégorie

### Structure

- Scaffold, SafeArea, Container

### Layout

- Column, Row, Center, SizedBox, Expanded, Stack

### Scroll

- SingleChildScrollView, ListView, ScrollController

### Formulaire

- Form, TextFormField, TextEditingController

### Boutons

- ElevatedButton, TextButton, IconButton, FloatingActionButton, GestureDetector

### Texte

- Text, Icon

### Navigation

- AppBar, Navigator

### Feedback

- CircularProgressIndicator, LinearProgressIndicator, SnackBar

### État

- ChangeNotifierProvider, Consumer, Provider.of

### Listes

- Card, ListTile, StreamBuilder, FutureBuilder

### Décoration

- BoxDecoration, ClipRRect

### Utilitaires

- Spacer, Divider, Padding

---

## Conseils d'Utilisation

1. **Toujours appeler `dispose()`** pour les controllers (TextEditingController, ScrollController, AudioPlayer)
2. **Utiliser `const`** quand possible pour optimiser les performances
3. **setState()** pour mettre à jour l'UI après un changement d'état
4. **Provider** pour partager l'état entre plusieurs widgets
5. **StreamBuilder** pour les données temps réel (Firestore)
6. **FutureBuilder** pour les opérations asynchrones ponctuelles
7. **GlobalKey** pour accéder à l'état d'un widget depuis l'extérieur

---

**Ce guide couvre tous les widgets utilisés dans VoiceUp. Référez-vous à ce document pour comprendre chaque élément de l'interface !** 🚀
