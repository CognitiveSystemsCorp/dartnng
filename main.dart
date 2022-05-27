import 'lib/dartnng.dart';
import 'dart:developer';
import 'dart:io';


void main() async {

    NNGSocket  socket = NNGSocket();
    final url = "tcp://*:6969";
    socket.pub0_open(url);

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

