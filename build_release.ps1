# Script de build automatisé pour l'APK de production
# Attendance App - Build Release

Write-Host "🚀 Début du build de production..." -ForegroundColor Green
Write-Host ""

# Étape 1 : Vérifier que nous sommes dans le bon dossier
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Erreur : Ce script doit être exécuté depuis le dossier racine du projet Flutter" -ForegroundColor Red
    exit 1
}

# Étape 2 : Vérifier que le keystore existe
if (-not (Test-Path "android\app\upload-keystore.jks")) {
    Write-Host "⚠️  Attention : Le keystore n'existe pas encore" -ForegroundColor Yellow
    Write-Host "📖 Consultez CREATE_KEYSTORE.md pour créer votre keystore" -ForegroundColor Yellow
    $response = Read-Host "Voulez-vous continuer quand même ? (o/n)"
    if ($response -ne "o") {
        exit 0
    }
}

# Étape 3 : Vérifier que key.properties existe
if (-not (Test-Path "android\key.properties")) {
    Write-Host "⚠️  Attention : Le fichier key.properties n'existe pas" -ForegroundColor Yellow
    Write-Host "📖 Créez le fichier android\key.properties avec vos informations de signature" -ForegroundColor Yellow
    $response = Read-Host "Voulez-vous continuer quand même ? (o/n)"
    if ($response -ne "o") {
        exit 0
    }
}

# Étape 4 : Nettoyer les builds précédents
Write-Host "🧹 Nettoyage des builds précédents..." -ForegroundColor Cyan
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors du nettoyage" -ForegroundColor Red
    exit 1
}

# Étape 5 : Récupérer les dépendances
Write-Host "📦 Récupération des dépendances..." -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors de la récupération des dépendances" -ForegroundColor Red
    exit 1
}

# Étape 6 : Analyser le code
Write-Host "🔍 Analyse du code..." -ForegroundColor Cyan
flutter analyze --no-fatal-warnings
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Des warnings ont été détectés, mais on continue..." -ForegroundColor Yellow
}

# Étape 7 : Demander le type de build
Write-Host ""
Write-Host "Choisissez le type de build :" -ForegroundColor Yellow
Write-Host "1. APK (pour tests et distribution directe)"
Write-Host "2. App Bundle AAB (recommandé pour Play Store)"
Write-Host "3. Les deux"
$choice = Read-Host "Votre choix (1/2/3)"

$buildApk = $false
$buildAab = $false

switch ($choice) {
    "1" { $buildApk = $true }
    "2" { $buildAab = $true }
    "3" { $buildApk = $true; $buildAab = $true }
    default { 
        Write-Host "❌ Choix invalide" -ForegroundColor Red
        exit 1
    }
}

# Étape 8 : Build APK
if ($buildApk) {
    Write-Host ""
    Write-Host "📱 Génération de l'APK de production..." -ForegroundColor Cyan
    flutter build apk --release
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erreur lors de la génération de l'APK" -ForegroundColor Red
        exit 1
    }
    
    $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
    if (Test-Path $apkPath) {
        $apkSize = (Get-Item $apkPath).Length / 1MB
        Write-Host "✅ APK généré avec succès !" -ForegroundColor Green
        Write-Host "📍 Emplacement : $apkPath" -ForegroundColor White
        Write-Host "📊 Taille : $([math]::Round($apkSize, 2)) MB" -ForegroundColor White
    }
}

# Étape 9 : Build App Bundle
if ($buildAab) {
    Write-Host ""
    Write-Host "📦 Génération de l'App Bundle (AAB)..." -ForegroundColor Cyan
    flutter build appbundle --release
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erreur lors de la génération de l'App Bundle" -ForegroundColor Red
        exit 1
    }
    
    $aabPath = "build\app\outputs\bundle\release\app-release.aab"
    if (Test-Path $aabPath) {
        $aabSize = (Get-Item $aabPath).Length / 1MB
        Write-Host "✅ App Bundle généré avec succès !" -ForegroundColor Green
        Write-Host "📍 Emplacement : $aabPath" -ForegroundColor White
        Write-Host "📊 Taille : $([math]::Round($aabSize, 2)) MB" -ForegroundColor White
    }
}

# Étape 10 : Résumé
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✨ Build terminé avec succès !" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Prochaines étapes :" -ForegroundColor Yellow
Write-Host "1. Testez l'APK sur un appareil réel"
Write-Host "2. Vérifiez toutes les fonctionnalités"
Write-Host "3. Préparez vos assets pour le Play Store (icônes, screenshots)"
Write-Host "4. Consultez BUILD_APK_GUIDE.md pour la publication"
Write-Host ""
Write-Host "🎉 Bonne chance pour votre publication !" -ForegroundColor Cyan
