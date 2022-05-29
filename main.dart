import 'lib/dartnng.dart';
import 'dart:developer';
import 'dart:io';


void main() async {

    /*

    NNGSocket  socket = NNGSocket();
    final url = 'tcp://*:6969';
    socket.pub0_open(url);

    */*/

    NNGSocket  socket = NNGSocket();
    final url = "tcp://127.0.0.1:4270";
    socket.sub0_open(url);
    socket.set_subscribe("");

    while (true) {
        String s = socket.recv();
        print("s $s");
    }

    //socket.close();

    /*
    int i = 0;
    while (true) {
        i += 1;
        String f = "i = ${i}";
        socket.send(f);
        print("${f}  ${f.length + 1}");
        sleep(Duration(seconds:1));
    }
    */
}

