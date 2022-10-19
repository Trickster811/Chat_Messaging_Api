import 'dart:io';
import 'dart:typed_data';

class ChatClient {
  final Socket socket;
  final String address;
  final int port;
  late String name;

  ChatClient({
    required this.socket,
    required this.address,
    required this.port,
    required this.name,
  });
}

class StanbyMessage {
  final ChatClient sender;
  final ChatClient receiver;
  final String message;

  const StanbyMessage({
    required this.sender,
    required this.receiver,
    required this.message,
  });
}

// Function to manage users and connections with them
void handleConnection(Socket client) {
  print('Connection from '
      '${client.remoteAddress.address}:${client.remotePort}');

  clients.add(ChatClient(
    socket: client,
    address: client.remoteAddress.address,
    port: client.remotePort,
    name: 'User 1',
  ));
  final x = clients.indexWhere((item) => item.port == client.remotePort);

  client.listen(
    // handle data from the client
    (Uint8List data) async {
      await Future.delayed(Duration(milliseconds: 500));

      // await File('new.jpg').writeAsBytes(data);
      final message = String.fromCharCodes(data);
      if (message.substring(message.length - 11) == "||_one_chat") {
        try {
          if (x != -1) {
            clients[x] = ChatClient(
              socket: client,
              address: client.remoteAddress.address,
              port: client.remotePort,
              name: message,
            );

            print(
                "A new user is connected with username::::${clients[x].name}");

            client.write(
                "Welcome to One Chat User ${clients[x].name}!\nTo send your message to someone, write your message with the name of the receiver\n");
            // client.write("You want to send your message to:");

            for (var element in clients) {
              if (element.port != client.remotePort) {
                write(
                  "There are ${clients.length - 1} users connected with you.\nUser -> ${clients[x].name}\n",
                  element,
                );

                write(
                  "There are ${clients.length - 1} users connected with you.\nUser -> ${element.name}\n",
                  client,
                );
              }
            }

            if (stanbyMessages.isNotEmpty) {
              for (var item in stanbyMessages) {
                if (item.receiver.name == clients[x].name) {
                  sendMessageOnConnection(item, clients);
                }
              }
            }
          }
        } catch (e) {
          print(
              ":::::::::::::::::\nYo Joachim, there's an error\n:::::::::::::\n$e\n::::::::::::::::");
        }
      }
      // if (message.substring(message.length - 19) == "||_one_chat_message") {
        print("The user ${clients[x].name} have said this ||==>||==> $message");
        distributeMessage(clients[x], message, clients, clients);

        // singleDistributionMessage(clients[x], clients[x + 1], message);
        // write(message, client);
      // }
    },

    // handle errors
    onError: (error) {
      print(error);
      errorHandler(
        error,
        clients[x],
        clients,
      );
    },

    // handle the client closing the connection
    onDone: () {
      finishedHandler(
        clients[x],
        clients,
      );
    },
  );
}

// List of all messages on stand by
List<StanbyMessage> stanbyMessages = [];

// List of connected users
List<ChatClient> clients = [];

void removeClient(ChatClient client, clients) {
  clients.remove(client);
}

void errorHandler(error, ChatClient client, clients) {
  print('${client.address}:${client.port} Error: $error');
  removeClient(client, clients);
  if (clients.length >= 1) {
    for (var element in clients) {
      write("User:\t${client.name}\tis diconnected.\n", element);
    }
  }
  client.socket.close();
}

void finishedHandler(ChatClient client, clients) {
  print('${client.address}:${client.port} Disconnected');
  removeClient(client, clients);
  if (clients.length >= 1) {
    for (var element in clients) {
      write("User:\t${client.name}\tis diconnected.\n", element);
    }
  }

  client.socket.close();
}

void write(String message, client) {
  print(message);

  if (client is ChatClient) {
    client.socket.write(message);
  } else {
    client.write(message);
  }
}

void distributeMessage(ChatClient client, String message,
    List<ChatClient> userList, List<ChatClient> receiverList) {
  for (ChatClient receiver in receiverList) {
    if (userList.contains(receiver)) {
      singleDistributionMessage(client, receiver, message);
    } else {
      final stanbyMessage = StanbyMessage(
        sender: client,
        receiver: receiver,
        message: message,
      );
      stanbyMessages.add(stanbyMessage);
    }
  }
}

void singleDistributionMessage(
  ChatClient client,
  ChatClient receiver,
  String message,
) {
  print(
      "This message:\t$message\nhave been sent to:\t${receiver.name}\nby:\t${client.name}");
  write(
    "You have sent message to: ${receiver.name}\t",
    client,
  );
  write(
    "You have received this message:\t$message\nfrom this user:\t${client.name}",
    receiver,
  );
}

void sendMessageOnConnection(
  StanbyMessage stanbyMessage,
  List<ChatClient> userList,
) {
  distributeMessage(
    stanbyMessage.sender,
    stanbyMessage.message,
    userList,
    [stanbyMessage.receiver],
  );
}

void groupDistributionMessage() {}
