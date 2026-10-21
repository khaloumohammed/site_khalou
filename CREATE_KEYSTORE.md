# Guide de création du Keystore pour signature APK

## 1. Créer le keystore

Ouvrez PowerShell dans le dossier `android/app` et exécutez :

```powershell
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

## 2. Répondez aux questions :

- **Mot de passe du keystore** : Choisissez un mot de passe fort (ex: `AttendanceApp2025!`)
- **Nom et prénom** : Votre nom
- **Nom de l'unité organisationnelle** : Votre organisation
- **Nom de l'organisation** : Votre entreprise
- **Nom de la ville** : Votre ville
- **Nom de l'état** : Votre région
- **Code pays** : MA (pour Maroc)

## 3. Sauvegarder les informations

**IMPORTANT** : Notez ces informations dans un endroit sûr :
- Mot de passe du keystore
- Alias : `upload`
- Emplacement du fichier : `android/app/upload-keystore.jks`

⚠️ **NE JAMAIS PERDRE CE FICHIER ET CE MOT DE PASSE !**
Sans eux, vous ne pourrez plus mettre à jour votre application sur le Play Store.
