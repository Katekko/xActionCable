import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../abstractions/web_socket.interface.dart';

class WebSocketIO implements IWebSocket {
  @override
  WebSocketChannel connect(
    Object url, {
    Iterable<String>? protocols,
    Map<String, dynamic>? headers,
    Duration? pingInterval,
  }) {
    return IOWebSocketChannel.connect(
      url,
      headers: headers,
      pingInterval: pingInterval,
    );
  }
}

IWebSocket getWebSocket() => WebSocketIO();
