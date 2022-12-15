import 'package:x_action_cable/types.dart';

class ActionCallback {
  final String name;
  final OnMessageRecieve callback;
  const ActionCallback({required this.name, required this.callback});
}
