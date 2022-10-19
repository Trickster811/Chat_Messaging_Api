import 'package:socket_server/socket_server.dart';

import 'dart:io';

// late ServerSocket server;

// void main() async {
//   HttpServer server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8083);
//   await for (HttpRequest req in server) {
//     if (req.uri.path == '/ws') {
//       WebSocketTransformer.upgrade(req).then((socket) {
//         socket.listen((data) {
//           print("from IP ${req.connectionInfo!.remoteAddress.address}:${data}");
//           socket.add("WebSocket Server:already received!");
//         });
//       });
//     }
//   }
// }

void main() {
  try {
    // bind the socket server to an address and port
    ServerSocket.bind(InternetAddress.anyIPv4, 4698).then((socket) {
      // listen for clent connections to the server
      // server = socket;
      socket.listen((client) {
        handleConnection(client);
      });
    });
  } catch (e) {
    print(
        "Oups!!! An error occured when starting the server\nHere's the error\n:::::::::::\n$e\n::::::::::::::\n");
  }
}

