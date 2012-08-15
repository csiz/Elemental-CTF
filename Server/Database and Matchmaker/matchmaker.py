import socket
import threading
import socketserver
import time
import struct
import hashlib

from socketstream import *


class GameServer:
	def __init__(self,stream,address,port,region):
        self.stream
		self.address = address
		self.port = port
		self.region = region
		self.available = 0

data = {}
data_lock = threading.RLock()


###############################################################################################################################
def Find(player_id):
    data_lock.acquire()

    for i in data:
        if data[i].available > 0:
            break
    else:
        data_lock.release()
        return None
        #nothing found

    response = (data[i].address,data[i].port)

    data[i].available --

    data[i].stream.write('i32s',1,player_id)

    data_lock.release()

    return response




###############################################################################################################################




def MessageDone(stream,id):
    pass

def AvailableSpaces(stream,id):
    (number,) = stream.read('i')
    data_lock.acquire()
    data[id].available = number
    data_lock.release()



###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
def RegisterServer(stream,address):#read (whats below), writes 1 or 0
    (id,password,region,port) = stream.read('32s32s32si')
    data_lock.acquire()
    if (hashlib.sha256(b'ep2').digest() == password) and (id not in data):
    	data[id] = GameServer(stream,address,port,region)
        data_lock.release()
        stream.write('i',1)
    else:
        data_lock.release()
        stream.write('i',0)
        id = None
    	raise Exception ("Invalid gameserver.")
    return id

MessageHandler = {#reads, returns:
    0:MessageDone,#nothing
    1:AvailableSpaces,#read int

}
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################

class ThreadedTCPRequestHandler(socketserver.BaseRequestHandler):
    def handle(self):
        stream = SocketStream(self.request)
        print ("Received gameserver connection from {}:{}".format(self.client_address[0],self.client_address[1]))
        try:
        	id = RegisterServer(stream)
            message_id = True
            while message_id:
                (message_id,) = stream.read('i')
                MessageHandler[message_id](stream,id)
        except Exception as error:
            print("A gameserver has been lost, the error was:",str(error))
        finally:
            stream.close()
            print ("Ended gameserver connection from {}:{}".format(self.client_address[0],self.client_address[1]))
            

class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    pass

class ServeForeverThread(threading.Thread):
    def run(self):
        HOST, PORT = '', 25972 #socket.gethostname(), 25971
        self.server = ThreadedTCPServer((HOST, PORT), ThreadedTCPRequestHandler)
        print ("Matchmaker listening on:",HOST,":",PORT," , in thread:",self.name)
        self.server.serve_forever()

    def stop(self):
        self.server.shutdown()
        print("Matchmaker has been shutdown.")
