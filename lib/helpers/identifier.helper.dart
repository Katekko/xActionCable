import 'dart:collection';
import 'dart:convert';

/// Helper to encode and decode the channel identifier
class IdentifierHelper {
  /// Used to pass (maybe) fix the name of the channel and put it in params
  static String encodeChanelId(String name, Map? params) {
    final fullChannelName = name.endsWith('Channel') ? name : '${name}Channel';

    /// Adding the channel name to params
    Map<String, dynamic> channelParams = params == null ? {} : Map.from(params);
    channelParams['channel'] ??= fullChannelName;

    return jsonEncode(SplayTreeMap.from(channelParams));
  }

  /// Used to parse the params sended from server
  static String parseChannelId(String identifier) {
    return jsonEncode(SplayTreeMap.from(jsonDecode(identifier)));
  }
}
