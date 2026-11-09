pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        // maven { url = uri("https://en-mirror.ir") }
        // 👈 مخازن اختصاصی Runflare برای این پروژه
            maven { url = uri("https://maven.myket.ir/") }
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    repositories {
        maven { url = uri("https://mirror-maven.runflare.com/android/maven2/") }
        maven { url = uri("https://mirror-maven.runflare.com/maven2/") }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // 👈 نسخه‌های تایید شده برای Flutter 3.44
    // id("com.android.application") version "9.0.1" apply false
    id("com.android.application") version "8.11.1" apply false

    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
    id("com.google.gms.google-services") version "4.4.1" apply false
    // id("com.google.gms.google-services") version "4.5.0" apply false
}

include(":app")