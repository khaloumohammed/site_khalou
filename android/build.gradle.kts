allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
plugins {
    // Les plugins Flutter et Android déjà présents
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    //id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false

    // 👈 NOUVEAU : Déclaration du plugin Google Services avec sa version.
    id("com.google.gms.google-services") version "4.4.4" apply false // ⚠️ Vérifiez la dernière version
    // Add the dependency for the Google services Gradle plugin


}
