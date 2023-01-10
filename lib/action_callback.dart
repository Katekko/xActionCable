import 'package:x_action_cable/types.dart';

/// Use this class to register yours callbacks from server
/// ```Dart
/// final actionCallback = ActionCallback(name: 'receive_message', callback: receiveMessage);
/// ```
class ActionCallback {
  final String name;
  final OnMessageRecieve callback;
  const ActionCallback({required this.name, required this.callback});
}
