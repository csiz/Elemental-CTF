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
	def __init__(self,id,server_id,private):
		self.id = id
		self.players = 0
		self.server = server_id
		self.private = private


servers = {}
rooms = {}
priority_sort = {}
servers_lock = threading.RLock()#this is a master lock atm



###############################################################################################################################
def CreateRoom(server_id,room_id = None,private = False):
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

		rooms[room_id] = GameRoom(room_id,server_id,private)
		servers[server_id].rooms[room_id] = rooms[room_id]

	return room_id

def SendPlayer(server,player_id,player_name,room_id):
	server.stream.write('i32s32s32s',1,player_id,player_name,room_id)

def Find(player_id,player_name,region):
	with servers_lock:
		if len(priority_sort[region]):
			if servers[priority_sort[region][0]].priority:
				server = servers[priority_sort[region][0]]
				room_id = None
				for room_id in server.rooms:
					if not server.rooms[room_id].private:
						if 0 < server.rooms[room_id].players < 10:
							break
				else:
					for room_id in server.rooms:
						if not server.rooms[room_id].private:
							if 10 <= server.rooms[room_id].players < 30:
								break
					else:
						room_id = CreateRoom(priority_sort[region][0])

				server.rooms[room_id].players += 1

			else:#highest priority for the region is 0
				return None
		else:#nothing in the priority list
			return None
		
	response = (server.address,server.port,room_id)
	SendPlayer(server,player_id,player_name,room_id)

	return response

def FindRoom(player_id,player_name,room_id,region):
	with servers_lock:
		if room_id not in rooms:
			if len(priority_sort[region]):
				if servers[priority_sort[region][0]].priority:
					server = servers[priority_sort[region][0]]
					CreateRoom(priority_sort[region][0],room_id,True)
				else:#highest priority for the region is 0
					return None
			else:#nothing in the priority list
				return None
		else:
			server = servers[rooms[room_id].server]

	response = (server.address,server.port,room_id)
	SendPlayer(server,player_id,player_name,room_id)
	return response


###############################################################################################################################




def MessageDone(stream,id):
	pass

def ServerState(stream,server_id):
	(priority,number_of_rooms) = stream.read('ii')
	temp_rooms = {}
	for i in range(number_of_rooms):
		(room_id,number_of_players) = stream.read('32si')
		temp_rooms[room_id] = number_of_players

	with servers_lock:
		servers[server_id].priority = priority
		new_rooms = {}
		old_rooms = servers[server_id].rooms
		for room_id in temp_rooms:
			if room_id in old_rooms:
				new_rooms[room_id] = old_rooms[room_id]
				new_rooms[room_id].players = temp_rooms[room_id]
				del old_rooms[room_id]
			else:
				new_rooms[room_id] = GameRoom(room_id,server_id)
				new_rooms[room_id].players = temp_rooms[room_id]
				rooms[room_id] = new_rooms[room_id]

		servers[server_id].rooms = new_rooms

		for room_id in old_rooms:
			if room_id in rooms:
				del rooms[room_id]

		temp_servers = {}
		for temp_server_id in servers:
			if servers[temp_server_id].region == servers[server_id].region:
				temp_servers [temp_server_id] = servers[temp_server_id]

		priority_sort[servers[server_id].region] = sorted(temp_servers, key = lambda id:temp_servers[id].priority, reverse = True)





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
	1:ServerState,#see implementation
	#todo, add new room updates

}
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################

def RemoveServer(server_id):
	with servers_lock:
		del servers[server_id]
		#todo also remove the rooms hosted by that server


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
				RemoveServer(id)
				

			

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
