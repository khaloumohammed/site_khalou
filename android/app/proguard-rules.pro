# Règles ProGuard pour l'application Attendance App

# Garder les annotations
-keepattributes *Annotation*

# Garder les numéros de ligne pour le débogage
-keepattributes SourceFile,LineNumberTable

# Garder les classes de Google Services
-keep class com.google.** { *; }
-dontwarn com.google.**

# Garder les classes Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Garder les classes Gson (si utilisé)
-keep class com.google.gson.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Garder les classes de modèles de données
-keep class com.boulhrouzi.attendance_app.data.models.** { *; }
-keep class com.boulhrouzi.attendance_app.domain.entities.** { *; }

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
