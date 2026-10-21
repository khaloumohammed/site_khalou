# Guide de Correction - Problème de Connexion Google

## État actuel

`android/app/google-services.json` contient maintenant des identifiants OAuth Android et Web (il ne contient plus le placeholder `NEW_CLIENT_ID_HERE`). Le client Web correspond à celui déclaré dans `lib/core/services/auth_service.dart` et les deux entrées Android ciblent le package `com.boulhrouzi.attendance_app`.

La présence de ces valeurs dans le dépôt ne permet pas de vérifier que les empreintes SHA-1 sont encore enregistrées dans Firebase/Google Cloud, que Google Sign-In est activé, ni que le compte utilisé est autorisé par l’écran de consentement OAuth. Si la connexion échoue après avoir choisi un compte, vérifiez ces réglages côté console.

---

## Solution : Régénérer google-services.json

### Étape 1 : Obtenir vos empreintes SHA

Exécutez cette commande dans le terminal (déjà lancée) :
```bash
cd android
./gradlew signingReport
```

Vous obtiendrez des empreintes SHA-1 et SHA-256 pour :
- **Debug** (pour le développement)
- **Release** (pour la production)

**Exemple de sortie :**
```
Variant: debug
Config: debug
Store: C:\Users\YourUser\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: 6C:27:47:1F:BA:B4:A2:9C:AF:8D:49:2C:92:62:81:FB:04:D3:C8:1E
SHA-256: ...
```

### Étape 2 : Ajouter les SHA dans Firebase Console

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet : **attendanceapp-475909**
3. Allez dans **Paramètres du projet** (icône engrenage)
4. Descendez à la section **Vos applications**
5. Cliquez sur votre app Android : `com.boulhrouzi.attendance_app`
6. Dans la section **Empreintes numériques de certificat SHA**, cliquez sur **Ajouter une empreinte**
7. Ajoutez **toutes** les empreintes SHA-1 obtenues (debug ET release)

### Étape 3 : Télécharger le nouveau google-services.json

1. Toujours dans Firebase Console, sur la page de votre app Android
2. Cliquez sur **Télécharger google-services.json**
3. Remplacez le fichier existant :
   ```
   android/app/google-services.json
   ```

### Étape 4 : Activer Google Sign-In dans Firebase

1. Dans Firebase Console, allez dans **Authentication**
2. Cliquez sur l'onglet **Sign-in method**
3. Activez **Google** comme fournisseur de connexion
4. Configurez l'email de support du projet

### Étape 5 : Vérifier la Console Google Cloud

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Sélectionnez le projet **attendanceapp-475909**
3. Allez dans **APIs & Services** > **Credentials**
4. Vérifiez que vous avez :
   - Un **OAuth 2.0 Client ID** de type Android
   - Un **OAuth 2.0 Client ID** de type Web (pour le backend)
5. Pour le client Android, vérifiez que :
   - Package name = `com.boulhrouzi.attendance_app`
   - Les empreintes SHA-1 sont correctement configurées

### Étape 6 : Activer les APIs nécessaires

Dans Google Cloud Console, activez ces APIs :
1. **Google Sheets API**
2. **Google Drive API**
3. **Google Sign-In API**

Allez dans **APIs & Services** > **Library** et recherchez chaque API pour l'activer.

### Étape 7 : Nettoyer et Reconstruire

```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

---

## Vérification Rapide

### Fichiers à vérifier :

1. **android/app/google-services.json**
   - Doit correspondre au projet Firebase et à l'identifiant d'application utilisés pour publier cette version.
   - Les empreintes SHA-1 doivent correspondre aux certificats de signature des variantes installées (debug, release ou Play App Signing).

2. **android/app/build.gradle.kts** ✅
   - Plugin google-services appliqué
   - Dépendances play-services-auth ajoutées

3. **lib/core/services/auth_service.dart** ✅
   - Scopes correctement définis
   - Gestion des timeouts présente

---

## Test de la Connexion

Après avoir suivi ces étapes :

1. Lancez l'application : `flutter run`
2. Cliquez sur le bouton de connexion Google
3. Sélectionnez votre compte Google
4. Acceptez les permissions demandées

Si la connexion échoue encore, vérifiez les logs :
```bash
flutter run --verbose
```

---

## Problèmes Courants

### "PlatformException(sign_in_failed)"
- Les empreintes SHA ne correspondent pas
- Régénérez google-services.json avec les bonnes SHA

### "ApiException: 10"
- Le client OAuth n'est pas configuré correctement
- Vérifiez Google Cloud Console > Credentials

### Timeout lors de la connexion
- Problème réseau ou firewall
- Vérifiez votre connexion Internet

---

## Vérifications côté console si le problème persiste

- Confirmer que Google Sign-In est activé dans Firebase Authentication.
- Enregistrer les empreintes SHA-1 debug/release et, si l'application est installée depuis Play, celle de Play App Signing.
- Vérifier le statut de l'écran de consentement OAuth et ajouter le compte à la liste des testeurs si l'application est en mode test.
- Vérifier que Google Sheets API et Google Drive API sont activées dans le projet concerné.
