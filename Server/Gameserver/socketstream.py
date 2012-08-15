import struct

class SocketStream:
    def __init__(self, socket):
        self.socket = socket
        self.file = self.socket.makefile('rwb')

    def read(self, fmt, *args):
        try:
            return struct.unpack('!'+fmt, self.file.read(struct.calcsize('!'+fmt)))
        except:
            self.close()
            raise

    def write(self, fmt, *args):
        try:
            self.file.write(struct.pack('!'+fmt,*args))
            self.file.flush()
        except:
            self.close()
            raise
    def close(self):
        self.socket.close()
        
