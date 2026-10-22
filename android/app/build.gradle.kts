import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseStorePath = providers.gradleProperty("giftedReleaseStoreFile").orNull
    ?: System.getenv("GIFTED_ANDROID_KEYSTORE_PATH")
val releaseStorePassword = providers.gradleProperty("giftedReleaseStorePassword").orNull
    ?: System.getenv("GIFTED_ANDROID_KEYSTORE_PASSWORD")
val releaseKeyAlias = providers.gradleProperty("giftedReleaseKeyAlias").orNull
    ?: System.getenv("GIFTED_ANDROID_KEY_ALIAS")
val releaseKeyPassword = providers.gradleProperty("giftedReleaseKeyPassword").orNull
    ?: System.getenv("GIFTED_ANDROID_KEY_PASSWORD")
val releaseCertificateSha256 = providers.gradleProperty("giftedReleaseCertificateSha256").orNull
    ?: System.getenv("GIFTED_ANDROID_CERT_SHA256")
val releaseSigningConfigured = listOf(
    releaseStorePath,
    releaseStorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
    releaseCertificateSha256,
).all { !it.isNullOrBlank() }

android {
    namespace = "com.siregifted.giftedproperty"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.siregifted.giftedproperty"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (releaseSigningConfigured) {
                storeFile = file(releaseStorePath!!)
                storePassword = releaseStorePassword!!
                keyAlias = releaseKeyAlias!!
                keyPassword = releaseKeyPassword!!
            }
        }
    }

    buildTypes {
        release {
            // Never silently fall back to the local debug signing configuration.
            signingConfig = if (releaseSigningConfigured) {
                signingConfigs.getByName("release")
            } else {
                null
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

tasks.register("validateReleaseSigning") {
    group = "verification"
    description = "Checks the release keystore, alias and expected certificate fingerprint."
    doLast {
        if (!releaseSigningConfigured) {
            throw GradleException(
                "Release builds require the keystore path/password, key alias/password, " +
                    "and the expected certificate SHA-256 fingerprint (GIFTED_ANDROID_CERT_SHA256 or giftedReleaseCertificateSha256).",
            )
        }

        val store = file(releaseStorePath!!)
        val alias = releaseKeyAlias!!
        if (!store.isFile) {
            throw GradleException("The configured Android release keystore file does not exist.")
        }
        if (store.name.equals("debug.keystore", ignoreCase = true) ||
            alias.equals("androiddebugkey", ignoreCase = true)
        ) {
            throw GradleException("The default Android debug keystore filename or alias cannot sign a release build.")
        }

        val isWindows = System.getProperty("os.name").startsWith("Windows", ignoreCase = true)
        val keytoolName = if (isWindows) "keytool.exe" else "keytool"
        val keytool = file("${System.getProperty("java.home")}/bin/$keytoolName")
        if (!keytool.isFile) {
            throw GradleException("keytool is not available in the active Java runtime.")
        }

        val processBuilder = ProcessBuilder(
            keytool.absolutePath,
            "-list",
            "-v",
            "-keystore",
            store.absolutePath,
            "-alias",
            alias,
            "-storepass:env",
            "GIFTED_ANDROID_KEYSTORE_PASSWORD",
            "-keypass:env",
            "GIFTED_ANDROID_KEY_PASSWORD",
        ).redirectErrorStream(true)
        processBuilder.environment()["GIFTED_ANDROID_KEYSTORE_PASSWORD"] = releaseStorePassword!!
        processBuilder.environment()["GIFTED_ANDROID_KEY_PASSWORD"] = releaseKeyPassword!!

        val process = processBuilder.start()
        val output = process.inputStream.bufferedReader().use { it.readText() }
        if (process.waitFor() != 0) {
            throw GradleException(
                "The configured Android release keystore, alias or credentials could not be validated.",
            )
        }

        val expectedFingerprint = releaseCertificateSha256!!
            .replace(":", "")
            .filterNot { it.isWhitespace() }
            .uppercase()
        if (!expectedFingerprint.matches(Regex("[A-F0-9]{64}"))) {
            throw GradleException("The expected release certificate fingerprint must be 64 hexadecimal characters.")
        }

        val actualFingerprint = Regex("(?m)^\\s*SHA256:\\s*([A-Fa-f0-9:]+)\\s*$")
            .find(output)
            ?.groupValues
            ?.get(1)
            ?.replace(":", "")
            ?.uppercase()
        if (actualFingerprint == null || actualFingerprint != expectedFingerprint) {
            throw GradleException("The configured release certificate does not match the expected SHA-256 fingerprint.")
        }
    }
}

tasks.configureEach {
    if (name == "assembleRelease" || name == "bundleRelease" || name == "packageRelease") {
        dependsOn("validateReleaseSigning")
    }
}
