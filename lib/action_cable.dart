import 'dart:async';
import 'dart:convert';

import 'package:x_action_cable/store/callbacks.store.dart';
import 'package:x_action_cable/types.dart';
import 'package:x_action_cable/web_socket/abstractions/web_socket.interface.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'action_callback.dart';
import 'action_channel.dart';
import 'helpers/identifier.helper.dart';
import 'helpers/handle_data.helper.dart';
import 'helpers/logger.helper.dart';

IWebSocket _webSocket = IWebSocket();

class ActionCable {
  /// Last ping to calculate when need to drop the connection
  /// because it passed 6 seconds without response from server
  DateTime? _lastPing;

  /// WebSocket for connect to ActionCable on rails
  late WebSocketChannel _socketChannel;

  /// Stream for listen data trough websocket
  late StreamSubscription _listener;

  /// Timer for helth check
  late Timer _timer;

  /// Factory for connect to ActionCable on Rails
  ActionCable.connect(
    String url, {
    Map<String, String> headers: const {},
    VoidCallback? onConnected,
    VoidCallback? onConnectionLost,
    required void Function(dynamic reason)? onCannotConnect,
  }) {
    final handleDataHelper = _createHandleDataHelper(
      onConnected: onConnected,
      onConnectionLost: onConnectionLost,
    );
    final socketChannel = _createSocketChannel(url: url, headers: headers);
    _addHandleDataListener(
      handleData: handleDataHelper,
      onCannotConnect: onCannotConnect,
      socketChannel: socketChannel,
    );
    _addHandleHelthCheckListener();
  }

  HandleDataHelper _createHandleDataHelper({
    required VoidCallback? onConnected,
    required VoidCallback? onConnectionLost,
  }) {
    return HandleDataHelper(
      onConnected: onConnected,
      onPingMessage: (time) => _lastPing,
    );
  }

  WebSocketChannel _createSocketChannel({
    required String url,
    required Map<String, String> headers,
  }) {
    // rails gets a ping every 3 seconds
    final socketChannel = _webSocket.connect(
      url,
      headers: headers,
      pingInterval: Duration(seconds: 3),
    );

    _socketChannel = socketChannel;

    return socketChannel;
  }

  void _addHandleDataListener({
    required WebSocketChannel socketChannel,
    required HandleDataHelper handleData,
    required void Function(dynamic message)? onCannotConnect,
  }) {
    _listener = socketChannel.stream.listen(
      handleData.onData,
      onError: (reason) {
        _disconnect(); // close a socket and the timer
        onCannotConnect?.call(reason);
      },
    );
  }

  void _disconnect() {
    _timer.cancel();
    _socketChannel.sink.close();
    _listener.cancel();
  }

  void _send(Map<String, dynamic> payload) {
    _socketChannel.sink.add(jsonEncode(payload));
    ActionLoggerHelper.log(payload);
  }

  void _addHandleHelthCheckListener() {
    _timer = Timer.periodic(const Duration(seconds: 3), _healthCheck);
  }

  void _healthCheck(_, {VoidCallback? onConnectionLost}) {
    if (_lastPing == null) return;
    if (DateTime.now().difference(_lastPing!) > Duration(seconds: 6)) {
      _disconnect();
      onConnectionLost?.call();
    }
  }

  /// Subscribe to a channel
  /// ```Dart
  /// void receiveMessage(Map payload) => print(payload);
  /// final actionCallback = ActionCallback(name: 'receive_message', callback: receiveMessage);
  ///
  ///  ActionChannel channel = cable.subscribe(
  ///   'Chat', // either 'Chat' and 'ChatChannel' is fine
  ///    channelParams: { 'room': 'private' },
  ///    onSubscribed: (){}, // `confirm_subscription` received
  ///    onDisconnected: (){}, // `disconnect` received
  ///    callbacks: [actionCallback] // Callback list to able the server  to call any method that you registered in your aplicaticon
  ///  );
  /// ```
  ActionChannel subscribe(
    String channelName, {
    Map? channelParams,
    VoidCallback? onSubscribed,
    VoidCallback? onDisconnected,
    List<ActionCallback> callbacks = const [],
  }) {
    final identifier = IdentifierHelper.encodeChanelId(
      channelName,
      channelParams,
    );

    CallbacksStore.subscribed[identifier] = onSubscribed;
    CallbacksStore.diconnected[identifier] = onDisconnected;
    CallbacksStore.message[identifier] = callbacks;

    _send({'identifier': identifier, 'command': 'subscribe'});

    return ActionChannel(identifier: identifier, sendMessageCallback: _send);
  }
}
