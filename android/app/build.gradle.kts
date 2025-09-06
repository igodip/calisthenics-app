plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.github.triplet.play") version "3.8.4"
}

/* ---- add these imports & top-level props ---- */
import java.util.Properties

// Load signing properties once, at top-level (visible everywhere below)
val propsFile = rootProject.file("key.properties")
val signingProps = Properties().also { p ->
    if (propsFile.exists()) {
        propsFile.inputStream().use { p.load(it) }
    }
}
/* --------------------------------------------- */

android {
    namespace = "com.idipaolo.calisync"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }

    defaultConfig {
        applicationId = "com.idipaolo.calisync"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (propsFile.exists()) {
                // In CI you wrote: storeFile=../app/my-release-key.jks
                storeFile = file(signingProps.getProperty("storeFile"))
                storePassword = signingProps.getProperty("storePassword")
                keyAlias = signingProps.getProperty("keyAlias")
                keyPassword = signingProps.getProperty("keyPassword")
            } else {
                println("⚠️ key.properties not found at ${propsFile.absolutePath}. Release will be UNSIGNED.")
            }
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

play {
    serviceAccountCredentials.set(rootProject.file("playstore-key.json"))
    track.set(providers.gradleProperty("PLAY_TRACK").orElse("alpha"))
    defaultToAppBundles.set(true)
}
