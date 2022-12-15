import 'dart:convert';

import 'package:action_cable/store/callbacks.store.dart';
import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

import '../types.dart';
import 'identifier.helper.dart';

class HandleDataHelper with CallbacksStore {
  final VoidCallback? _onConnected;
  final OnPingMessage _onPingMessage;

  HandleDataHelper({
    required VoidCallback? onConnected,
    required OnPingMessage onPingMessage,
  })  : _onConnected = onConnected,
        _onPingMessage = onPingMessage;

  void onData(dynamic payload) {
    payload = jsonDecode(payload);

    if (payload['type'] != null) {
      _handleProtocolMessage(payload);
    } else {
      _handleDataMessage(payload);
    }
  }

  void _handleProtocolMessage(Map payload) {
    switch (payload['type']) {
      case 'ping':
        _onPing(payload);
        break;
      case 'welcome':
        _onWelcome();
        break;
      case 'disconnect':
        _onDisconnected(payload);
        break;
      case 'confirm_subscription':
        _onConfirmSubscription(payload);
        break;
      case 'reject_subscription':
        _onRejectSubscription();
        break;
      default:
        throw 'InvalidMessage';
    }
  }

  void _handleDataMessage(Map<String, dynamic> payload) {
    final channelId = IdentifierHelper.parseChannelId(payload['identifier']);
    final onMessageCallback = CallbacksStore.message[channelId];
    if (onMessageCallback == null) {
      Logger().e('Currently you are disconnected from channel = $channelId');
      return;
    }

    final methodName = payload['message']['method'] as String?;
    if (methodName == null) {
      Logger().e(
        'The server it\'s not sending the method on payload. Try to add a "method" key on json in your server.\nMessage: ${payload}',
      );
      return;
    }

    final actionCallback = onMessageCallback.firstWhereOrNull(
      (e) => e.name.toLowerCase() == methodName.toLowerCase(),
    );

    if (actionCallback == null) {
      Logger().e(
        'Server tried to send a message that the application did not register with ActionCallback.\nTry to register when you go to subscribe to a channel.\nMethod: ${payload['message']['method']}',
      );
      return;
    }

    actionCallback.callback(payload['message']);
  }

  void _onPing(Map payload) {
    // rails sends epoch as seconds not miliseconds
    final lastPing = DateTime.fromMillisecondsSinceEpoch(
      payload['message'] * 1000,
    );
    _onPingMessage(lastPing);
  }

  void _onWelcome() => _onConnected?.call();

  void _onDisconnected(Map payload) {
    final channelId = IdentifierHelper.parseChannelId(payload['identifier']);
    final onDisconnected = CallbacksStore.diconnected[channelId];
    onDisconnected?.call();
  }

  void _onConfirmSubscription(Map payload) {
    final channelId = IdentifierHelper.parseChannelId(payload['identifier']);
    final onSubscribed = CallbacksStore.subscribed[channelId];
    if (onSubscribed != null) {
      onSubscribed();
    }
  }

  void _onRejectSubscription() {}
}
