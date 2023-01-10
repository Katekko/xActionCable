import 'dart:developer' as dev;

class ActionLoggerHelper {
  static bool isActivated = false;
  static bool ping = false;
  static bool action = true;
  static bool protocol = true;
  static bool message = true;

  static String? log(Map<String, dynamic> data) {
    if (!isActivated) return null;
    if (!protocol && data['type'] != null) return null;
    if (!ping && data['type'] == 'ping') return null;
    if (!action &&
        data.containsKey('command') &&
        data['command'] == 'message') {
      return null;
    }

    String name = '';
    if (data['type'] != null) {
      name = '| PROTOCOL |';
      if (data['type'] == 'ping') name += '~ PING ~';
    } else if (data.containsKey('command') && data['command'] == 'message') {
      name = '| PERFOMING ACTION |';
    }

    final dataString = data.toString();
    dev.log(dataString, name: name);
    return dataString;
  }
}
