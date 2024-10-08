// ignore_for_file: constant_identifier_names

import 'package:real_time_chat_app/core/utils/constants/enums.dart';

class AppEnvironment {
  static const DEV_ENVIRONMENT = DEV_ENVIRONMENT_ENUM.PRODUCTION;

  static bool isProductionEnv() {
    return AppEnvironment.DEV_ENVIRONMENT == DEV_ENVIRONMENT_ENUM.PRODUCTION;
  }

  static bool isDevelopmentEnv() {
    return AppEnvironment.DEV_ENVIRONMENT == DEV_ENVIRONMENT_ENUM.DEVELOPMENT;
  }

  static bool isTestEnv() {
    return AppEnvironment.DEV_ENVIRONMENT == DEV_ENVIRONMENT_ENUM.TEST;
  }
}
