import pynng
import msgpack

rep = pynng.Rep0(listen="tcp://*:4269", send_timeout=1000)
while True:
    cmd = msgpack.loads(rep.recv())
    print(cmd)
    resp = {'ok' : True}
    rep.send(msgpack.dumps(resp))
