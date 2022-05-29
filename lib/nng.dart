library dartnng;
import 'bindings.dart';

import 'dart:typed_data';
import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;


String _platformPath(final String name, {String? path}) {
  path = path ?? '';
  if (Platform.isLinux || Platform.isAndroid) {
    return p.join(path, 'lib' + name + '.so');
  }
  if (Platform.isMacOS) {
    return p.join(path, 'lib' + name + '.dylib');
  }
  if (Platform.isWindows) {
    return p.join(path, name + '.dll');
  }
  throw Exception('Platform not implemented');
}
DynamicLibrary _loadBinding(final String name,
    {final String? path}) {
  String fullPath = _platformPath(name, path: path);
  return DynamicLibrary.open(fullPath);
}

// Keep the finalizer itself reachable, otherwise might not do anything.


typedef PosixFreeNative = Void Function(Pointer<Void>);
DynamicLibrary _c = _loadBinding('nng');
nng _n = nng(_c);


void close(final Pointer<nng_socket> ref) {
  print("close token $ref");
  _n.nng_close(ref.ref);
  //ref.close();
}
//Does not fire in time
//final Finalizer _finalizer = Finalizer<Pointer<nng_socket>>(close);

final NativeFinalizer _finalizer = NativeFinalizer(_n.addresses.nng_close_ptr.cast<NativeFunction<PosixFreeNative>>());

class NNGSocket implements Finalizable {
  late Pointer<nng_socket> sock_ptr;
  late nng n; 
  bool _closed = false;
  NNGSocket() {
    n = _n;
    sock_ptr = malloc.allocate<nng_socket>(0);

     //_finalizer.attach(this, sock_ptr.cast<Void>(), detach: this);
     _finalizer.attach(this, sock_ptr.cast<Void>());
  }

  void pub0_open(final String url) {
    int ret = n.nng_pub0_open(sock_ptr);
    check_err(ret);
    final urlNative = url.toNativeUtf8().cast<Char>();
    ret = n.nng_listen(sock_ptr.ref, urlNative, nullptr, 0);
    check_err(ret);
    malloc.free(urlNative);
  }

  void sub0_open(final String url) {
    int ret;
    ret = n.nng_sub0_open(sock_ptr);
    check_err(ret);
    final urlNative = url.toNativeUtf8().cast<Char>();
    ret = n.nng_dial(sock_ptr.ref, urlNative, nullptr, NNG_FLAG_NONBLOCK);
    check_err(ret);
    malloc.free(urlNative);
  }

  void set_subscribe(final String prefix) {
      final prefixNative = prefix.toNativeUtf8().cast<Void>();
      final subNative = NNG_OPT_SUB_SUBSCRIBE.toNativeUtf8().cast<Char>();
      int ret = n.nng_setopt(sock_ptr.ref, subNative, prefixNative, 0);
      malloc.free(prefixNative);
      malloc.free(subNative);
      check_err(ret);
  }

  Uint8List recv() {
        Pointer<Pointer<Char>> buf = malloc.allocate<Pointer<Char>>(0);
        Pointer<Size> sz = malloc.allocate<Size>(0);
        Uint8List bytes;
        try {

            int ret = n.nng_recv(sock_ptr.ref, buf.cast<Void>(), sz, NNG_FLAG_ALLOC);
            check_err(ret);
            final data = buf.value.cast<Uint8>();
            bytes = Uint8List.fromList(data.asTypedList(sz.value));
            //string = String.fromCharCodes(bytes);
            //print("got $dataList $string");
            //string = buf.value.cast<Utf8>().toDartString();
            n.nng_free(buf.value.cast<Void>(), sz.value);
        } finally {
            malloc.free(buf);
            malloc.free(sz);
        }
        return bytes;
  }


  void send(final Uint8List data) {
    var outBuf = malloc.allocate<Uint8>(data.length);
    var outdata = outBuf.asTypedList(data.length);
    outdata.setAll(0, data);
    try {
        int ret = n.nng_send(sock_ptr.ref, outBuf.cast<Void>(), data.length, 0);
        check_err(ret);
    } finally {
        malloc.free(outBuf);
    }
  }

  void close() {
    if (!_closed) {
      int ret = n.nng_close(sock_ptr.ref);
      check_err(ret);
      malloc.free(sock_ptr);
      _closed = true;
      _finalizer.detach(this);
    }
  }
  void check_err(final int err) {
    if (err == 0) {
        return;
    }
    String msg = n.nng_strerror(err).cast<Utf8>().toDartString();
    throw NNGException(msg);
  }
}

class NNGException implements Exception {
  final String msg;
  NNGException(this.msg);
  String toString() => 'NNGException : $msg';
}
