plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.daric_new"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.example.daric_new"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    // جلوگیری از فعال بودن ویژگی‌های native که باعث NDK install میشن
    buildFeatures {
        aidl = false
        renderScript = false
        shaders = false
        mlModelBinding = false
        prefab = false
        buildConfig = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isShrinkResources = false
            isMinifyEnabled = false

            // جلوگیری از پردازش فایل‌های .so
            ndk {
                debugSymbolLevel = "none"
            }
            packagingOptions {
                doNotStrip.add("**/*.so")
            }
        }
    }


    
}

flutter {
    source = "../.."
}
