// ignore_for_file: constant_identifier_names, camel_case_types

enum DEV_ENVIRONMENT_ENUM { DEVELOPMENT, TEST, PRODUCTION }

enum NAVIGATION_TYPE { PUSH_NAMED, POP, POP_TO_ROOT, PUSH_REPLACEMENT_NAMED, POP_UNTIL, POP_UNTIL_OR_PUSH_NAMED }

class EnumHandler {
  static T? enumFromString<T extends Enum>(Iterable<T> values, String? value) {
    if (value == null) {
      return null;
    }
    try {
      for (T amenityValue in values) {
        if (amenityValue.name == value.toString().toUpperCase()) {
          return amenityValue;
        }
      }
    } catch (e) {
      return values.first;
    }
    return null;
  }

  static String? stringFromEnum(dynamic value) {
    if (value == null) {
      return null;
    }
    return value.toString().split('.').last.toLowerCase();
  }
}
