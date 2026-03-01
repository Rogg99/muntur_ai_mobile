# Flutter-specific keep rules
-keep class io.flutter.** { *; }
-keep class dev.flutter.** { *; }

# Pour les composants différés (SplitInstall)
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**

## Keep rules for agora and desugaring
#-keep class com.google.devtools.build.android.desugar.runtime.** { *; }

# Pour le desugaring
-keep class com.google.devtools.build.android.desugar.runtime.** { *; }
-dontwarn com.google.devtools.build.android.desugar.runtime.**

# Keep all classes used by agora
-keep class io.agora.** { *; }

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Optional: For better R8 performance
-dontwarn org.codehaus.mojo.animal_sniffer.*
-dontwarn javax.annotation.**

# Optional: Keep annotations
-keepattributes *Annotation*

# Prevent obfuscation of main app classes
-keep class dev.munturai.** { *; }
