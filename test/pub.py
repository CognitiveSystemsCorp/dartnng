import pynng
NNG_DATA_SOCKET ="tcp://*:4270"
pub = pynng.Pub0(listen=NNG_DATA_SOCKET)
import time
import msgpack

while True:
    msg = {'a' : 1.0, 2 : 'b'}
    pub.send(msgpack.packb(msg))
    print(msg)
    time.sleep(1)
