import 'dart:io';
import 'dart:typed_data';

late Socket socket;

void onConnection(Socket socket) {
  socket.write("Joachim||_one_chat");

  socket.listen(
    // handle data from the server
    (Uint8List data) async {
      print(String.fromCharCodes(data));
    },
    onError: errorHandler,
    onDone: () => doneHandler(socket),
    cancelOnError: false,
  );
}

void dataHandler(data) {
  // print(String.fromCharCodes(data).trim());
  // handle data from the server

  (Uint8List data) async {
    print(String.fromCharCodes(data).trim());
  };
}

void errorHandler(error, StackTrace trace) {
  print(
      "Coucou !!!!!\n::::::::::::::::Here is the error::::::::::::\n$error\n:::::::::::::");
}

void doneHandler(Socket socket) {
  print('Good job Server!!!');
  // socket.destroy();
  connectionTask();
  // exit(0);
}

Future<void> sendMessage(Socket socket, List<int> data) async {
  // stdin.readLineSync();
  socket.write('${String.fromCharCodes(data).trim()}||_one_chat_message\n');
  await Future.delayed(Duration(milliseconds: 500));
}

connectionTask() {
  Socket.connect("localhost", 4698).then((Socket sock) {
    socket = sock;
    onConnection(sock);
  }).catchError((e) {
    print(
        ":::::::::::::\nUnable to connect to a server with the given port\n::::::::::::::\n$e\n:::::::::::::\n");
    // exit(1);
    connectionTask();
  });
}
