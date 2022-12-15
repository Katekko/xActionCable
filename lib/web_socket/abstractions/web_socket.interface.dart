import 'package:web_socket_channel/web_socket_channel.dart';

import '../imp/web_socket_stub.dart'
    if (dart.library.io) '../imp/web_socket_io.dart'
    if (dart.library.html) '../imp/web_socket_web.dart';

abstract class IWebSocket {
  WebSocketChannel connect(
    String url, {
    Iterable<String>? protocols,
    Map<String, dynamic>? headers,
    Duration? pingInterval,
  });

  factory IWebSocket() => getWebSocket();
}
