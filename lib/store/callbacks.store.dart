import 'package:x_action_cable/types.dart';

mixin CallbacksStore {
  static Map<String, VoidCallback?> subscribed = {};
  static Map<String, VoidCallback?> diconnected = {};
  static OnMessageCallbacks message = {};
}
