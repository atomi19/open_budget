import 'dart:io';

class AppPlatform {
  static bool get isMobile => 
    Platform.isAndroid || 
    Platform.isIOS;

  static bool get isDesktop => 
    Platform.isLinux ||
    Platform.isWindows ||
    Platform.isMacOS;
}