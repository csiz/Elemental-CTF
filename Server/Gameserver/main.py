#todo

#create games
#run games




import socket
import threading
import socketserver
import time
import struct
import hashlib
import copy

from socketstream import *
from game import * #GameRoom,Player class import


SERVER,SERVER_PORT = 'localhost', 25972
HOST, PORT = '', 25973 #socket.gethostname(), 25971
ID = b'1'
PASSWORD = hashlib.sha256(b'ep2').digest()
REGION = b'local'



rooms = {}
rooms_lock = threading.RLock()

class Incoming:
	def __init__(self,id,room_id):
		self.id = id
		self.room_id = room_id

players = {}
players_lock = threading.RLock()



def PlayerLost(player,room):
	pass
	#todo, what to do in case an error

def MessageDone(stream,player,room):
	pass
	#todo, remove plaer successfully

def Synchronize(stream,player,room):
	stream.write('f',time.time() - room.time)

def GetID(stream,player,room):
	stream.write('i',player.id)

def ReceivePlayerState(stream,player,room):
	(state_number,id,team,time,count) = stream.read('iiifi')

	if id != player.id:
		raise Exception("Haven't requested the information of another player.")
		#todo, receiving information about another player for cheat/sync check

	objects = []
	for i in range(count):
		(unique,role,flavor,x,y,vx,vy,hp) = stream.read('iiifffff')
		objects.append(Object(unique,role,flavor,x,y,vx,vy,hp))

	with room.lock:
		if room.state_number == state_number:
			player.team = team
			player.time = time
			player.objects = objects
		#otherwise, casually discard data


def SendGameState(stream,player,room):
	nr_of_bytes = 12
	players_to_send = []

	with room.lock:
		for id in room.players:
			if id != player.id:
				nr_of_bytes += 16 + ( 32 * len(room.players[id].objects) )
				players_to_send.append(copy.deepcopy(room.players[id]))

		actions_to_send = player.actions
		player.actions = []

		state_number = room.state_number

	nr_of_bytes += 8 * len(actions_to_send)

	stream.write('i',nr_of_bytes)

	stream.write('iii',state_number,len(actions_to_send),len(players_to_send))

	for a in actions_to_send:
		stream.write('if',a.id,a.time)
	
	for p in players_to_send:
		stream.write('iifi', p.id, p.team, p.time, len(p.objects))
		for o in p.objects:
			stream.write('iiifffff', o.unique, o.role, o.flavor, o.x, o.y, o.vx, o.vy, o.health)

def ReceiveAction(stream,player,room):
	(time,) = stream.read('f')
	with room.lock:
		for id in room.players:
			if id != player.id:
				room.players[id].actions.append(Action(player.id,time))


def SendGameOverview(stream,player,room):
	with room.lock:
		state_number = room.state_number
		level = room.level

	stream.write('ii',state_number,level)


###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
def RegisterPlayer(stream):#read player id, writes 1(success) or 0(fail) or 2(keep waiting) ... after sending 1, wait for a synchronize
	(id,) = stream.read('32s')
	for i in range(10):
		with players_lock:
			if id in players:
				room_id = players[id].room_id
				del players[id]
				break
		stream.write('i',2)
		time.sleep(1)
	else:
		stream.write('i',0)
		raise Exception("Could not find player in alloted time.")
		return None

	with rooms_lock:
		if room_id in rooms:
			room = rooms[room_id]
			player = room.NewPlayer()
		else:
			stream.write('i',0)
			raise Exception("The room was disbanded before the player could join.")
			return None
	try:
		stream.write('i',1)

		(sync_request,) = stream.read('i')
		if sync_request == 1:
			Synchronize(stream,player,room)
		else:
			raise Exception("Player failed to send a synchronize request.")
			return None
	except:
		#if an error happenede there, then remove the player from game room
		room.RemovePlayer(player)

	return (player,room)


MessageHandler = {#reads, returns:
	0:MessageDone,#nothing
	1:Synchronize,#write f time
	2:GetID,#write i player.id
	3:ReceivePlayerState,#complicated, see implementation
	4:SendGameState,#complicated, see implementation
	5:ReceiveAction,#read float
	7:SendGameOverview,#writes 'ii' (state number and level)


}
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################

class ThreadedTCPRequestHandler(socketserver.BaseRequestHandler):
	def handle(self):
		stream = SocketStream(self.request)
		print ("Received connection from {}:{}".format(self.client_address[0],self.client_address[1]))
		player,room = None,None
		try:
			(player,room) = RegisterPlayer(stream)
			message_id = True
			while message_id:
				(message_id,) = stream.read('i')
				MessageHandler[message_id](stream,player,room)
		except Exception as error:
			print("A player has been lost, the error was:",str(error))
			PlayerLost(player,room)
		finally:
			if room:
				room.RemovePlayer(player)
			stream.close()
			print ("Ended connection from {}:{}".format(self.client_address[0],self.client_address[1]))
			

class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
	pass

class ServeForeverThread(threading.Thread):
	def run(self):
		self.server = ThreadedTCPServer((HOST, PORT), ThreadedTCPRequestHandler)
		print ("Gameserver listening on:",HOST,":",PORT," , in thread:",self.name)
		self.server.serve_forever()

	def stop(self):
		self.server.shutdown()
		print("Gameserver has been shutdown.")




def ConnectionEnded(stream):
	pass

def IncomingPlayer(stream):
	(player_id,room_id) = stream.read('32s32s')
	print("Incoming player:",player_id,"in room:",room_id)
	with players_lock:
		if player_id not in players:
			players[player_id] = Incoming(player_id,room_id)
		players[player_id].room_id = room_id

		with rooms_lock:
			if room_id not in rooms:
				#create a new room and stuff
				rooms[room_id] = GameRoom()
	

###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################


MatchmakerHandler = {
	0:ConnectionEnded,
	1:IncomingPlayer,

	
}

###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################

def MatchmakerWriter(stream):
	while(True):
		stream.write('ii',1,10)#todo this is priority
		time.sleep(60)


def MatchmakerReader(stream):
	try:
		message_id = True
		while message_id:
			(message_id,) = stream.read('i')
			MatchmakerHandler[message_id](stream)
	except Exception as error:
		print("Connection to matchmaker lost.",str(error))
	finally:
		stream.close()



if __name__ == "__main__":
	#start gameserver
	server_thread = ServeForeverThread()
	server_thread.start()

	#connect to matchmaker
	matchmaker = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	matchmaker.connect((SERVER,SERVER_PORT))
	stream = SocketStream(matchmaker)

	stream.write('32s32s32si',ID,PASSWORD,REGION,PORT)
	(response,) = stream.read('i')
	if response == 1:
		print("Connected to matchmaker.")
	else:
		print("Failed to connect to matchmaker.")
		server_thread.stop()
	
	#start the 2 threads
	matchmaker_reader_thread = threading.Thread(target = MatchmakerReader, args = (stream,))
	matchmaker_reader_thread.start()

	matchmaker_writer_thread = threading.Thread(target = MatchmakerWriter, args = (stream,))
	matchmaker_writer_thread.daemon = True
	matchmaker_writer_thread.start()
