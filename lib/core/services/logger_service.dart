// ignore_for_file: avoid_print

import '../utils/constants/app_environment.dart';

class LoggerService {
  static log(Object? logMessage) {
    if (AppEnvironment.isDevelopmentEnv()) {
      print(logMessage);
    }
  }
}
