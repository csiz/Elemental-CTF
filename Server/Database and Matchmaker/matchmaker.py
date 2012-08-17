import socket
import threading
import socketserver
import time
import struct
import hashlib
import random

from socketstream import *


class GameServer:
	def __init__(self,stream,address,port,region):
		self.stream = stream
		self.address = address
		self.port = port
		self.region = region
		self.priority = 0
		self.rooms = {}

class GameRoom:
	def __init__(self,id,server_id):
		self.id = id
		self.players = 0
		self.server = server_id
		self.private = False
		self.full = False

servers = {}
rooms = {}
servers_lock = threading.RLock()#this is a master lock atm



###############################################################################################################################
def CreateRoom(server_id,room_id = None):
	with servers_lock:
		if room_id == None:
			room_id = str(random.randrange(1, 2**31 - 1)).encode()
			for i in range(len(room_id),32):
				room_id += b'\x00'
			while room_id in rooms:
				room_id = str(random.randrange(1, 2**31 - 1)).encode()
				for i in range(len(room_id),32):
					room_id += b'\x00'
		else:
			if room_id in rooms:
				return None

		rooms[room_id] = GameRoom(room_id,server_id)
		servers[server_id].rooms[room_id] = rooms[room_id]

	return room_id



def Find(player_id):#todo add room here, so players can request custom rooms
	with servers_lock:

		for i in servers:
			if servers[i].priority > 0:#todo find max priority
				break
		else:
			return None
			#nothing found

		server = servers[i]
		room_id = None

		for x in server.rooms:
			if not server.rooms[x].full:
				room_id = server.rooms[x].id
				break
		else:
			room_id = CreateRoom(i)

		response = (server.address,server.port,room_id)


	server.stream.write('i32s32s',1,player_id,room_id)#todo this will block, and the function could be called inside a lock

	return response




###############################################################################################################################




def MessageDone(stream,id):
	pass

def PriorityChange(stream,id):
	(number,) = stream.read('i')
	with servers_lock:
		servers[id].priority = number



###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
def RegisterServer(stream,address):#read (whats below), writes 1 or 0
	(id,password,region,port) = stream.read('32s32s32si')
	servers_lock.acquire()
	if (hashlib.sha256(b'ep2').digest() == password) and (id not in servers):
		servers[id] = GameServer(stream,address,port,region)
		servers_lock.release()
		stream.write('i',1)
	else:
		servers_lock.release()
		stream.write('i',0)
		id = None
		raise Exception ("Invalid gameserver.")
	return id

MessageHandler = {#reads, returns:
	0:MessageDone,#nothing
	1:PriorityChange,#read int
	#todo, add new room updates

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
			id = RegisterServer(stream,self.client_address[0].encode())
			message_id = True
			while message_id:
				(message_id,) = stream.read('i')
				MessageHandler[message_id](stream,id)
		except Exception as error:
			print("A gameserver has been lost, the error was:",str(error))
		finally:
			stream.close()
			print ("Ended gameserver connection from {}:{}".format(self.client_address[0],self.client_address[1]))
			if id:
				with servers_lock:
					del servers[id]
					#todo also remove the rooms hosted by that server

			

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
