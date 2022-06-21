import pynng

NNG_DATA_SOCKET ="tcp://127.0.0.1:4270"
sub = pynng.Sub0(dial=NNG_DATA_SOCKET, block_on_dial=False)
sub.subscribe(b'')

while True:
    print(sub.recv())
