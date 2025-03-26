-keep class com.google.crypto.tink.** { *; }
-keep class javax.annotation.** { *; }
-keep class com.google.errorprone.annotations.** { *; }
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-keepattributes *Annotation*
-keepattributes Signature
-dontwarn sun.misc.Unsafe 

-keep class com.google.api.client.** { *; }
-keep class com.google.http.** { *; }
-keep class org.joda.time.** { *; }
-dontwarn com.google.api.client.**
-dontwarn com.google.http.**
-dontwarn org.joda.time.**
-dontwarn javax.annotation.**
-dontwarn org.apache.http.**
-dontwarn com.google.auto.value.AutoValue
-dontwarn com.google.auto.value.AutoValue$Builder 

-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Play Core
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.** 