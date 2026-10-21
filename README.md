# Attendance App

Application Flutter de gestion des présences et pointages, intégrée avec Google Sheets.

## Description

Attendance App est une application mobile développée avec Flutter permettant de gérer efficacement les présences des élèves. L'application s'intègre directement avec Google Sheets pour stocker et synchroniser les données en temps réel.

## Fonctionnalités principales

- **Authentification Google** : Connexion sécurisée via Google Sign-In
- **Gestion des classes** : Organisation et suivi des différentes classes
- **Gestion des élèves** : Ajout, modification et consultation des informations des élèves
- **Gestion des séances** : Création et suivi des séances de cours
- **Pointage** : Enregistrement des présences, absences et retards
- **Synchronisation Google Sheets** : Sauvegarde automatique des données dans Google Sheets
- **Interface moderne** : Design épuré et intuitif avec Material Design 3

## Prérequis

- Flutter SDK (version 3.9.2 ou supérieure)
- Compte Google avec accès à Google Drive et Google Sheets
- Configuration OAuth 2.0 pour l'authentification Google

## Installation

1. Cloner le repository
2. Installer les dépendances :
   ```bash
   flutter pub get
   ```
3. Configurer les credentials Google OAuth 2.0
4. Lancer l'application :
   ```bash
   flutter run
   ```

## Architecture

Le projet suit une architecture Clean Architecture avec :
- **Presentation Layer** : BLoC/Cubit pour la gestion d'état
- **Domain Layer** : Entités et use cases métier
- **Data Layer** : Repositories et sources de données
- **Dependency Injection** : GetIt pour l'injection de dépendances

## Technologies utilisées

- Flutter & Dart
- BLoC/Cubit (flutter_bloc)
- Google Sign-In
- Google Sheets API
- GoRouter pour la navigation
- Google Fonts pour la typographie

## Licence

Tous droits réservés.
=======
# site_khalou
Site personnel
