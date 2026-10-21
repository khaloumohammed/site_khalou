# Guide complet de génération d'APK pour Play Store

## 📋 Prérequis

- Flutter installé et configuré
- Android SDK installé
- Java JDK 11 ou supérieur

## 🔑 Étape 1 : Créer le Keystore (À faire UNE SEULE FOIS)

### 1.1 Ouvrir PowerShell dans le dossier du projet

```powershell
cd C:\Users\SuperElectro\AttendanceProject\attendance_app\android
```

### 1.2 Générer le keystore

```powershell
keytool -genkey -v -keystore app\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 1.3 Répondre aux questions

- **Mot de passe** : Choisissez un mot de passe FORT (ex: `AttendanceApp2025!`)
- **Nom et prénom** : Votre nom complet
- **Unité organisationnelle** : Votre département/équipe
- **Organisation** : Votre entreprise
- **Ville** : Votre ville
- **État/Province** : Votre région
- **Code pays** : MA (pour Maroc)

⚠️ **IMPORTANT** : Sauvegardez le fichier `upload-keystore.jks` et le mot de passe dans un endroit SÛR !

## 📝 Étape 2 : Créer le fichier key.properties

### 2.1 Créer le fichier

Créez le fichier `android/key.properties` avec ce contenu :

```properties
storePassword=VOTRE_MOT_DE_PASSE
keyPassword=VOTRE_MOT_DE_PASSE
keyAlias=upload
storeFile=app/upload-keystore.jks
```

Remplacez `VOTRE_MOT_DE_PASSE` par le mot de passe que vous avez choisi.

### 2.2 Vérifier que key.properties est dans .gitignore

Le fichier `key.properties` ne doit JAMAIS être commité sur Git !

## 🏗️ Étape 3 : Nettoyer et préparer le build

```powershell
# Nettoyer les builds précédents
flutter clean

# Récupérer les dépendances
flutter pub get

# Vérifier qu'il n'y a pas d'erreurs
flutter analyze
```

## 📦 Étape 4 : Générer l'APK de production

### Option A : APK standard (recommandé pour tests)

```powershell
flutter build apk --release
```

L'APK sera généré dans : `build\app\outputs\flutter-apk\app-release.apk`

### Option B : App Bundle (recommandé pour Play Store)

```powershell
flutter build appbundle --release
```

Le bundle sera généré dans : `build\app\outputs\bundle\release\app-release.aab`

## 🎯 Étape 5 : Tester l'APK

### 5.1 Installer sur un appareil physique

```powershell
flutter install --release
```

### 5.2 Vérifier les fonctionnalités

- ✅ Connexion Google
- ✅ Accès aux Google Sheets
- ✅ Gestion des élèves
- ✅ Pointage
- ✅ Génération des rapports

## 📤 Étape 6 : Préparer pour le Play Store

### 6.1 Fichiers nécessaires

1. **App Bundle** : `app-release.aab` (recommandé) ou **APK** : `app-release.apk`
2. **Icône de l'application** : 512x512 px (PNG)
3. **Feature Graphic** : 1024x500 px (PNG)
4. **Screenshots** : Au moins 2 captures d'écran (téléphone)
5. **Description courte** : Max 80 caractères
6. **Description complète** : Max 4000 caractères
7. **Politique de confidentialité** : URL obligatoire

### 6.2 Informations de l'application

**Nom** : Gestion Présences
**Package** : com.boulhrouzi.attendance_app
**Version** : 1.0.0 (Code: 1)
**Catégorie** : Productivité / Éducation

### 6.3 Description suggérée

**Courte** :
```
Application de gestion des présences et pointages avec Google Sheets
```

**Complète** :
```
Gestion Présences est une application professionnelle de suivi des présences et des pointages, 
parfaitement intégrée avec Google Sheets.

✨ Fonctionnalités principales :
• Connexion sécurisée avec Google
• Gestion des classes et des élèves
• Pointage rapide et intuitif
• Synchronisation automatique avec Google Sheets
• Génération de rapports d'absence
• Interface moderne et intuitive
• Support multilingue (Français/Arabe)

📊 Avantages :
• Gain de temps considérable
• Données centralisées et accessibles
• Aucune perte de données
• Facile à utiliser
• Gratuit et sans publicité

🎯 Idéal pour :
• Établissements scolaires
• Centres de formation
• Associations
• Entreprises

Téléchargez maintenant et simplifiez votre gestion des présences !
```

## 🔍 Étape 7 : Vérifications finales

### Checklist avant publication

- [ ] L'APK/AAB est signé correctement
- [ ] La version est correcte dans `pubspec.yaml`
- [ ] L'icône de l'application est professionnelle
- [ ] Toutes les fonctionnalités marchent en mode release
- [ ] Pas de données de test dans l'APK
- [ ] La politique de confidentialité est prête
- [ ] Les screenshots sont de qualité
- [ ] La description est complète et sans fautes

## 🚀 Étape 8 : Publication sur Play Store

1. Aller sur https://play.google.com/console
2. Créer une nouvelle application
3. Remplir toutes les informations
4. Uploader l'App Bundle (AAB)
5. Soumettre pour révision

⏱️ **Délai de révision** : 1-7 jours généralement

## 📱 Commandes utiles

```powershell
# Voir la taille de l'APK
flutter build apk --release --analyze-size

# Générer un APK par ABI (plus petit)
flutter build apk --release --split-per-abi

# Vérifier la signature de l'APK
keytool -printcert -jarfile build\app\outputs\flutter-apk\app-release.apk

# Lister les fichiers dans l'APK
jar tf build\app\outputs\flutter-apk\app-release.apk
```

## ⚠️ Problèmes courants

### Erreur : "Keystore not found"
- Vérifiez que `upload-keystore.jks` existe dans `android/app/`
- Vérifiez le chemin dans `key.properties`

### Erreur : "Wrong password"
- Vérifiez le mot de passe dans `key.properties`

### APK trop volumineux
- Utilisez `--split-per-abi` pour générer des APK plus petits
- Ou utilisez App Bundle (AAB) qui optimise automatiquement

## 📞 Support

Pour toute question, consultez :
- Documentation Flutter : https://flutter.dev/docs/deployment/android
- Play Console Help : https://support.google.com/googleplay/android-developer

---

**Bonne chance pour votre publication ! 🎉**
