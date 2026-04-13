
-keep class com.follow.clash.models.**{ *; }

-keep class com.follow.clash.service.models.**{ *; }

# AIDL interfaces & Stubs -- required for cross-process binder communication
-keep class com.follow.clash.service.I*          { *; }
-keep class com.follow.clash.service.I*$Stub     { *; }
-keep class com.follow.clash.service.I*$Stub$Proxy { *; }

# Service infrastructure in common module
-keep class com.follow.clash.common.ServiceDelegate { *; }
-keep class com.follow.clash.common.GlobalState     { *; }
-keep class com.follow.clash.common.Components      { *; }

# Keep service extension functions (bindServiceFlow etc.)
-keepclassmembers class com.follow.clash.common.ExtKt { *; }

# Keep Android service / provider classes (supplement AAPT auto-keeps)
-keep class com.follow.clash.service.RemoteService  { *; }
-keep class com.follow.clash.service.VpnService      { *; }
-keep class com.follow.clash.service.CommonService   { *; }
-keep class com.follow.clash.service.FilesProvider   { *; }

# Kotlin coroutines -- don't strip ServiceConnection callback internals
-keepclassmembers class * implements android.content.ServiceConnection {
    public void onServiceConnected(android.content.ComponentName, android.os.IBinder);
    public void onServiceDisconnected(android.content.ComponentName);
}