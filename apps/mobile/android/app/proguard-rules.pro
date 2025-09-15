# Flutter wrapper - KEEP ALL
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Google ML Kit - Core
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# ML Kit Text Recognition - Language specific (we don't use these)
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Assume no side effects for unused language recognizers
-assumenosideeffects class com.google.mlkit.vision.text.chinese.** { *; }
-assumenosideeffects class com.google.mlkit.vision.text.devanagari.** { *; }
-assumenosideeffects class com.google.mlkit.vision.text.japanese.** { *; }
-assumenosideeffects class com.google.mlkit.vision.text.korean.** { *; }

# Google Play Core
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Supabase
-keep class io.supabase.** { *; }
-keep class com.supabase.** { *; }

# Background Service
-keep class id.flutter.flutter_background_service.** { *; }

# SQLite
-keep class io.sqflite.** { *; }
-keep class com.tekartik.** { *; }

# General Android
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception