library dartnng;
import 'bindings.dart';

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
  late Pointer<nng_listener> listener_ptr;
  late nng n; 
  bool _closed = false;
  NNGSocket() {
    n = _n;
    sock_ptr = malloc.allocate<nng_socket>(0);
    listener_ptr = malloc.allocate<nng_listener>(0);

     //_finalizer.attach(this, sock_ptr.cast<Void>(), detach: this);
     _finalizer.attach(this, sock_ptr.cast<Void>());
  }

  void pub0_open(final String url) {
    int ret = n.nng_pub0_open(sock_ptr);
    check_err(ret);
    final urlNative = url.toNativeUtf8().cast<Char>();
    ret = n.nng_listen(sock_ptr.ref, urlNative, listener_ptr, 0);
    check_err(ret);
    malloc.free(urlNative);
  }

  void send(final String data) {
    final fs = data.toNativeUtf8();
    int ret = n.nng_send(sock_ptr.ref, fs.cast<Void>(), data.length + 1, 0);
    check_err(ret);
    malloc.free(fs);
  }

  void close() {
    if (!_closed) {
      int ret = n.nng_close(sock_ptr.ref);
      check_err(ret);
      malloc.free(sock_ptr);
      malloc.free(listener_ptr);
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
