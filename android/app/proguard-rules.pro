# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep our services (referenced in AndroidManifest)
-keep class com.sakunia.auto_tap.ClickerAccessibilityService { *; }
-keep class com.sakunia.auto_tap.OverlayService { *; }
-keep class com.sakunia.auto_tap.ClickerState { *; }
-keep class com.sakunia.auto_tap.MainActivity { *; }

# Keep Kotlin companion object methods (used via static access)
-keepclassmembers class com.sakunia.auto_tap.** {
    public static <methods>;
    public static <fields>;
}

# AndroidX
-keep class androidx.core.** { *; }
-dontwarn androidx.core.**
