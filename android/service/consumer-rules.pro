# Service module consumer rules -- propagated to app module
-keep class com.follow.clash.service.I* { *; }
-keep class com.follow.clash.service.I*$Stub { *; }
-keep class com.follow.clash.service.I*$Stub$Proxy { *; }
-keep class com.follow.clash.service.RemoteService { *; }
-keep class com.follow.clash.service.VpnService { *; }
-keep class com.follow.clash.service.CommonService { *; }
-keep class com.follow.clash.service.FilesProvider { *; }
