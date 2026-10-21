# ✅ Checklist de publication Play Store

## 🔐 Étape 1 : Sécurité et Signature

- [ ] Keystore créé (`upload-keystore.jks`)
- [ ] Fichier `key.properties` configuré
- [ ] Mot de passe du keystore sauvegardé en lieu sûr
- [ ] Keystore sauvegardé (backup dans un endroit sécurisé)
- [ ] `key.properties` ajouté au `.gitignore`

## 📱 Étape 2 : Configuration de l'application

- [ ] Nom de l'application correct dans `AndroidManifest.xml` : "Gestion Présences"
- [ ] `applicationId` unique : `com.boulhrouzi.attendance_app`
- [ ] Version correcte dans `pubspec.yaml` : `1.0.0+1`
- [ ] Permissions nécessaires ajoutées (INTERNET, ACCESS_NETWORK_STATE)
- [ ] Icône de l'application professionnelle

## 🎨 Étape 3 : Assets pour le Play Store

### Obligatoires
- [ ] **Icône de l'application** : 512x512 px (PNG, sans transparence)
- [ ] **Feature Graphic** : 1024x500 px (PNG ou JPG)
- [ ] **Screenshots** : Minimum 2, maximum 8 (téléphone)
  - Résolution : 320px - 3840px
  - Format : PNG ou JPG
  - Ratio : 16:9 ou 9:16

### Recommandés
- [ ] Screenshots tablette (optionnel)
- [ ] Vidéo promotionnelle YouTube (optionnel)
- [ ] Banner promo : 180x120 px (optionnel)

## 📝 Étape 4 : Contenu textuel

- [ ] **Titre de l'application** (max 50 caractères)
  ```
  Gestion Présences
  ```

- [ ] **Description courte** (max 80 caractères)
  ```
  Gestion des présences et pointages avec Google Sheets
  ```

- [ ] **Description complète** (max 4000 caractères)
  - Fonctionnalités principales listées
  - Avantages clairs
  - Public cible défini
  - Sans fautes d'orthographe

- [ ] **Catégorie** choisie : Productivité ou Éducation

- [ ] **Tags/Mots-clés** définis

## 🔒 Étape 5 : Politique de confidentialité

- [ ] URL de la politique de confidentialité créée
- [ ] Politique hébergée sur un site accessible
- [ ] Politique conforme au RGPD
- [ ] Mention de l'utilisation de Google Services
- [ ] Mention de la collecte de données (si applicable)

## 🏗️ Étape 6 : Build de production

- [ ] Code nettoyé (pas de debug, pas de TODO)
- [ ] `flutter analyze` sans erreurs critiques
- [ ] Tests effectués en mode release
- [ ] APK/AAB généré avec succès
- [ ] Taille de l'APK raisonnable (< 50 MB idéalement)

## 🧪 Étape 7 : Tests

### Tests fonctionnels
- [ ] Connexion Google fonctionne
- [ ] Accès aux Google Sheets OK
- [ ] Gestion des classes fonctionne
- [ ] Ajout/modification/suppression d'élèves OK
- [ ] Pointage fonctionne correctement
- [ ] Synchronisation avec Google Sheets OK
- [ ] Génération de rapports OK
- [ ] Navigation fluide

### Tests de compatibilité
- [ ] Testé sur Android 5.0+ (API 21+)
- [ ] Testé sur différentes tailles d'écran
- [ ] Testé avec connexion lente
- [ ] Testé sans connexion (comportement approprié)
- [ ] Rotation d'écran gérée correctement

### Tests de performance
- [ ] Pas de crash
- [ ] Pas de freeze/lag
- [ ] Consommation batterie raisonnable
- [ ] Utilisation mémoire acceptable

## 📤 Étape 8 : Soumission Play Store

- [ ] Compte Google Play Developer créé (25$ one-time fee)
- [ ] Informations de contact remplies
- [ ] Certificat de contenu complété
- [ ] Classification du contenu effectuée
- [ ] Prix défini (Gratuit ou Payant)
- [ ] Pays de distribution sélectionnés
- [ ] App Bundle (AAB) uploadé
- [ ] Version de test interne créée (optionnel mais recommandé)

## 📊 Étape 9 : Informations supplémentaires

- [ ] **Email de contact** fourni
- [ ] **Site web** (optionnel mais recommandé)
- [ ] **Adresse physique** (obligatoire dans certains pays)
- [ ] **Numéro de téléphone** (optionnel)

## 🎯 Étape 10 : Avant la soumission finale

- [ ] Toutes les captures d'écran sont de qualité
- [ ] La description est attractive et sans fautes
- [ ] L'icône est professionnelle et reconnaissable
- [ ] La version de test a été validée (si applicable)
- [ ] Les métadonnées sont en français (ou multilingue)
- [ ] Le questionnaire de contenu est complété
- [ ] Les déclarations de confidentialité sont faites

## 🚀 Publication

- [ ] Soumission effectuée
- [ ] Email de confirmation reçu
- [ ] Statut "En révision" visible dans la console

## ⏱️ Après soumission

**Délai de révision** : 1-7 jours généralement

### Pendant la révision
- [ ] Surveiller les emails de Google
- [ ] Vérifier régulièrement la Play Console
- [ ] Préparer les réponses aux questions potentielles

### Après approbation
- [ ] Application publiée ✅
- [ ] Lien Play Store partagé
- [ ] Monitoring des avis et notes
- [ ] Réponse aux commentaires utilisateurs
- [ ] Planification des mises à jour

## 📱 Liens utiles

- **Play Console** : https://play.google.com/console
- **Documentation Flutter** : https://flutter.dev/docs/deployment/android
- **Guide des assets** : https://support.google.com/googleplay/android-developer/answer/9866151
- **Politique de confidentialité** : https://support.google.com/googleplay/android-developer/answer/9859455

---

## 🎉 Félicitations !

Une fois toutes ces étapes complétées, votre application sera prête pour le Play Store !

**Bonne chance ! 🚀**
