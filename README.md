![Pub](https://img.shields.io/pub/v/action_cable)

# ActionCable in Dart

(This is a fork from https://pub.dev/packages/action_cable)

ActionCable is the default realtime websocket framework and protocol in Rails.

This is a dart port of the client and protocol implementation which is available in web, dartVM and flutter.

The difference between this libs and others, is some patterns we are using here. Exemple the way that your server response need to match what we are expecting, and improving the code based on last features from dart (I know we still have some code to be improved) See more bellow. 

## Usage

### Connecting to a cable 🙌

```dart
final cable = ActionCable.connect(
  'ws://127.0.0.1:3000/cable',
  headers: {
    'Authorization': 'jwt-token',
  },
  onConnected: (){
    print('connected');
  }, 
  onConnectionLost: () {
    print('connection lost');
  }, 
  onCannotConnect: () {
    print('cannot connect');
});
```

### Subscribing to channel 🎉

```dart
void receiveMessage(Map payload) => print(payload);
final actionCallback = ActionCallback(name: 'receive_message', callback: receiveMessage);

ActionChannel channel = cable.subscribe(
  'Chat', // either 'Chat' and 'ChatChannel' is fine
  channelParams: { 'room': 'private' },
  onSubscribed: (){}, // `confirm_subscription` received
  onDisconnected: (){}, // `disconnect` received
  callbacks: [actionCallback] // Callback list to able the server  to call any method that you registered in your aplicaticon 
);
```
When your server send the key 'receive_message' in their payload, the lib will be able to identify and call the callback correctly.

See the example bellow explaining what the server need to send:

```Ruby
ActionCable.server.broadcast("notifications_#{current_user}", {method: "receive_message", data: { anyData: [1, 2, 3] } })
```

Above we have on the second parameter the key method, that's all the lib need to see what callback call on client side.

Also with this ActionChannel you will be able to perform action from the channel object, see more bellow.

### Unsubscribing from a channel 🎃

First lets see how we can unsubscribe from a channel.
Remember the ActionChannel that you created? You will use the same object to unsubribe itself.

```dart
channel.unsubscribe();
```

Just it, don't need nothing more. Lets see how perform an action client calling the server

### Perform an action on your ActionCable server 🎇

Again, remember the object that you created above? The channel? We will use itself to perform an action.

```dart
channel.performAction(
  action: 'send_message',
  actionParams: { 'message': 'Hello private peeps! 😜' }
);
```

Here we have some other parameters.
ACTION: will be the name of your server side method that you are trying to call
actionParams: will be the parameters that you pass to the server

Bellow we have a method example in ruby on rails

```Ruby
def send_message(data)
  puts("message: #{data}")
end
```

### Disconnect from the ActionCable server

And now, for the disconnect you will need to use the main object (ActionCable) to disconect the websocket.

```dart
cable.disconnect();
```

## ActionCable protocol

Anycable has [a great doc](https://docs.anycable.io/#/misc/action_cable_protocol) on that topic.

## Contributors ✨

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
