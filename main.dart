import 'lib/dartnng.dart';
import 'dart:developer';
import 'dart:io';

import 'dart:async';
import 'dart:isolate';
import "package:msgpack_dart/msgpack_dart.dart" as msg;

rx(SendPort sendPort) async {
    NNGSocket  socket = NNGSocket();
    final url = "tcp://127.0.0.1:4270";
    socket.sub0_open(url);
    socket.set_subscribe("");

    while (true) {
        var s = socket.recv();
        sendPort.send(s);
    }
}



void main() async {

/*
     var receivePort = new ReceivePort();
     await Isolate.spawn(rx, receivePort.sendPort);
     final b = receivePort.asBroadcastStream();

     final listener = b.listen(
        (event) {
        var m = msg.deserialize(event);
        print('event: $m');
     },
        onDone: () => print('Done'),
     );

    while (true) {
        await Future.delayed(const Duration(seconds: 1));
    }
    */


    NNGSocket  socket = NNGSocket();
    final url = 'tcp://*:6969';
    socket.pub0_open(url);

    int i = 0;
    while (true) {
        i += 1;
        String f = "i = ${i}";
        Map<String, dynamic> JSON = {
            "1": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            "2": i
        };
        var m = msg.serialize(JSON);
        socket.send(m);
        print(JSON);
        sleep(Duration(seconds:1));
    }
}

