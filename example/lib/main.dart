import 'package:flutter/material.dart';
import 'package:x_action_cable/action_cable.dart';
import 'package:x_action_cable/action_callback.dart';
import 'package:x_action_cable/action_channel.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ActionCable cable;
  late final ActionChannel channel;

  @override
  void initState() {
    super.initState();
    // Connecting to a cable webscoket first, so after you will connect to a channel
    cable = ActionCable.connect(
      'ws://chat.example.com/cable',
      headers: {'Authorization': 'Some Token'},
      onConnected: onConnected,
      onConnectionLost: onConnectionLost,
      onCannotConnect: onCannotConnect,
    );

    // Subscribe to a channel for receive messages through the server
    // The callbacks parameter is all the methods that the server can call in the frontend application
    // First you need to define a ActionCallback
    // The name parameter is the name that your server will call
    // and the callback parameter is the method the lib will call based on the name
    // That's it, if your server send a message with paramether "method": "on_receive_message",
    // the lib will call onReceiveMessage for you.
    // Thats what the lib is expecting from the server: {"method": "on_receive_message", "data": "any message here"}
    final onMessageCallback = ActionCallback(
      name: 'on_receive_message',
      callback: onReceiveMessage,
    );

    channel = cable.subscribe(
      'Chat',
      onSubscribed: onChannelSubscribed,
      callbacks: [onMessageCallback],
    );
  }

  void onConnected() => debugPrint('connected');
  void onConnectionLost() => debugPrint('connection lost');
  void onCannotConnect(dynamic reason) => debugPrint(reason.toString());

  void onChannelSubscribed() {
    debugPrint('Subscribed to the ChatChannel');
    // After you subscribed to the channel, you can start send actions to it
    // The first parameter is the method's name in the server that you are trying to call
    // And the [params] is the data that you need to send to the server
    channel.performAction(
      'send_message',
      params: {'message': 'Hello World'},
    );
  }

  void onReceiveMessage(Map<String, dynamic> data) {
    final message = data['data']['message'];
    debugPrint(message);
  }

  @override
  void dispose() {
    // Just to finish, you can now disconect all of your channels
    channel.unsubscribe();

    // Your cable is disconected automatically when you disconect from the webscoket
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Example showing how the lib works!\nCurrently we don\'t have any server to suply the example. Be patient',
        ),
      ),
    );
  }
}
