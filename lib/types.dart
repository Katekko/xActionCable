import 'action_callback.dart';

typedef VoidCallback = void Function();
typedef OnPingMessage = void Function(DateTime lastPing);
typedef OnMessageRecieve = void Function(Map<String, dynamic> message);
typedef SendMessageCallback = void Function(Map<String, dynamic> payload);
typedef OnMessageCallbacks = Map<String, List<ActionCallback>?>;
