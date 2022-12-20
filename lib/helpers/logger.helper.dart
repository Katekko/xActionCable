import 'package:logger/logger.dart';

class ActionLoggerHelper {
  static bool isActivated = false;
  static bool ping = false;
  static bool action = true;
  static bool protocol = true;
  static bool message = true;

  static void log(Map<String, dynamic> data) {
    if (!isActivated) return;
    if (!protocol && data['type'] != null) return;
    if (!ping && data['type'] == 'ping') return;
    if (!action &&
        data.containsKey('command') &&
        data['command'] == 'message') {
      return;
    }

    Logger().i(data);
  }
}
