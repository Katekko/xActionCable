import 'dart:convert';

import 'package:action_cable/store/callbacks.store.dart';
import 'package:action_cable/types.dart';

class ActionChannel {
  final String identifier;
  final SendMessageCallback _sendMessageCallback;

  ActionChannel({
    required this.identifier,
    required SendMessageCallback sendMessageCallback,
  }) : _sendMessageCallback = sendMessageCallback;

  void unsubscribe() {
    CallbacksStore.subscribed.remove(identifier);
    CallbacksStore.diconnected.remove(identifier);
    CallbacksStore.message.remove(identifier);

    final command = {'identifier': identifier, 'command': 'unsubscribe'};
    _sendMessageCallback(command);
  }

  void performAction({
    String? action,
    Map<String, dynamic>? params,
  }) {
    params ??= {};
    params['action'] = action;

    final command = {
      'identifier': identifier,
      'command': 'message',
      'data': jsonEncode(params)
    };

    _sendMessageCallback(command);
  }
}
