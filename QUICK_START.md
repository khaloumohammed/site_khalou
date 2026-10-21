# 🚀 Guide Rapide - Génération APK

## Étapes rapides (5 minutes)

### 1️⃣ Créer le Keystore (PREMIÈRE FOIS SEULEMENT)

```powershell
cd android
keytool -genkey -v -keystore app\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Choisissez un mot de passe fort et NOTEZ-LE !**

### 2️⃣ Créer key.properties

Créez le fichier `android/key.properties` :

```properties
storePassword=VOTRE_MOT_DE_PASSE
keyPassword=VOTRE_MOT_DE_PASSE
keyAlias=upload
storeFile=app/upload-keystore.jks
```

### 3️⃣ Générer l'APK

#### Option A : Utiliser le script automatique (RECOMMANDÉ)

```powershell
.\build_release.ps1
```

#### Option B : Commandes manuelles

```powershell
# Nettoyer
flutter clean

# Récupérer les dépendances
flutter pub get

# Générer l'APK
flutter build apk --release

# OU générer l'App Bundle (pour Play Store)
flutter build appbundle --release
```

### 4️⃣ Récupérer les fichiers

**APK** : `build\app\outputs\flutter-apk\app-release.apk`

**AAB** : `build\app\outputs\bundle\release\app-release.aab`

---

## 📚 Documentation complète

- **Guide détaillé** : `BUILD_APK_GUIDE.md`
- **Checklist publication** : `PUBLICATION_CHECKLIST.md`
- **Création keystore** : `CREATE_KEYSTORE.md`

---

## ⚡ Commandes utiles

```powershell
# Installer l'APK sur un appareil connecté
flutter install --release

# Voir la taille de l'APK
flutter build apk --release --analyze-size

# Générer des APK séparés par architecture (plus petits)
flutter build apk --release --split-per-abi

# Vérifier la signature
keytool -printcert -jarfile build\app\outputs\flutter-apk\app-release.apk
```

---

## 🆘 Problèmes courants

### "Keystore not found"
➡️ Vérifiez que `upload-keystore.jks` est dans `android/app/`

### "Wrong password"
➡️ Vérifiez le mot de passe dans `key.properties`

### "Signing config not found"
➡️ Vérifiez que `key.properties` existe dans `android/`

---

**C'est tout ! Votre APK est prêt pour le Play Store ! 🎉**
