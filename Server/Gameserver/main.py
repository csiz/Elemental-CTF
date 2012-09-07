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


#SERVER,SERVER_PORT = 'localhost', 25972
SERVER,SERVER_PORT = "86.122.32.2", 25972
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
		self.time = time.time()

players = {}
players_lock = threading.RLock()



def PlayerLost(player,room):
	pass
	#todo, what to do in case an error

def MessageDone(stream,player,room):
	pass
	#todo, remove plaer successfully

def Flush(stream,player,room):
	stream.flush()

def StopFlushing(stream,player,room):
	pass

def FlushButNotNow(stream,player,room):
	pass


def Synchronize(stream,player,room):
	stream.write('f',time.time() - room.time)

def GetID(stream,player,room):
	stream.write('i',player.id)

def ReceivePlayerState(stream,player,room):
	(state_number,id,team,time,count) = stream.read('iiifi')
	if id == 0:
		state_number = -1
		#silently ignore
	elif id != player.id:
		raise Exception("Haven't requested the information of another player.")
		#todo, receiving information about another player for cheat/sync check

	objects = []
	for i in range(count):
		(unique,role,flavor,x,y,vx,vy,hp) = stream.read('iiifffff')
		objects.append(Object(unique,role,flavor,x,y,vx,vy,hp))

	with room.lock:
		if state_number == room.state_number:
			player.team = team
			player.time = time
			player.objects = objects
		#otherwise, casually discard data


def SendGameState(stream,player,room):
	nr_of_bytes = 20 + 24#20 for state_number, actions, damages, chat, players, 24 is 2*12 for flags
	players_to_send = []

	with room.lock:
		for id in room.players:
			if (id != player.id) and ( abs(time.time() - room.time - room.players[id].time) < 1.5 ):
				nr_of_bytes += 16 + ( 32 * len(room.players[id].objects) )
				players_to_send.append(copy.deepcopy(room.players[id]))

		actions_to_send = player.actions
		player.actions = []

		damages_to_send = player.damages
		player.damages = []

		chat_to_send = player.chat
		player.chat = []

		flags = copy.deepcopy(room.flags)

		state_number = room.state_number

	nr_of_bytes += 8 * len(actions_to_send)

	nr_of_bytes += 16 * len(damages_to_send)

	nr_of_bytes += 68 * len(chat_to_send)

	stream.write('i',nr_of_bytes)

	stream.write('iiiii',state_number,len(actions_to_send),len(damages_to_send),len(chat_to_send),len(players_to_send))

	for a in actions_to_send:
		stream.write('if',a.unique,a.time)

	for d in damages_to_send:
		stream.write('ffii',d.time,d.damage,d.target,d.source)

	for c in chat_to_send:
		stream.write('i64s',c.id,c.text)

	for p in players_to_send:
		stream.write('iifi', p.id, p.team, p.time, len(p.objects))
		for o in p.objects:
			stream.write('iiifffff', o.unique, o.role, o.flavor, o.x, o.y, o.vx, o.vy, o.health)

	for f in flags:
		stream.write('ffi',flags[f].x,flags[f].y,flags[f].unique)

	#time.sleep(0.1)#artficial lag
	


def ReceiveAction(stream,player,room):
	(state_number,unique,time) = stream.read('iif')
	with room.lock:
		if state_number == room.state_number:
			for id in room.players:
				if id != player.id:
					room.players[id].actions.append(Action(unique,time))

def ReceiveDamage(stream,player,room):
	(state_number,time,damage,player_id_target,unique_target,unique_source) = stream.read('iffiii')
	with room.lock:
		if state_number == room.state_number:
			if player_id_target in room.players:
				for o in room.players[player_id_target].objects:
					if o.unique == unique_target:
						o.health -= damage
				room.players[player_id_target].damages.append(Damage(time,damage,unique_target,unique_source))

def ReceiveChat(stream,player,room):
	(state_number,text) = stream.read('i64s')
	with room.lock:
		if state_number == room.state_number:
			for id in room.players:
				room.players[id].chat.append(Chat(player.id,text))

def SendGameOverview(stream,player,room):
	with room.lock:
		state_number = room.state_number
		level = room.level

	stream.write('ii',state_number,level)

def ReceiveFlagState(stream,player,room):
	(state_number,flag,x,y,unique) = stream.read('iiffi')
	with room.lock:
		if state_number == room.state_number:
			room.flags[flag].unique = unique
			room.flags[flag].x = x
			room.flags[flag].y = y

def ReceiveWin(stream,player,room):
	(state_number,team) = stream.read('ii')
	with room.lock:
		if state_number == room.state_number:
			if not room.win:
				player.win = team
				count = 0
				for id in room.players:
					if room.players[id].win == team:
						count += 1

				if count >= (len(room.players)/2):
					room.Win(team)



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
		stream.flush()
		time.sleep(1)
	else:
		stream.write('i',0)
		stream.flush()
		raise Exception("Could not find player in alloted time.")
		return None

	with rooms_lock:
		if room_id in rooms:
			room = rooms[room_id]
			player = room.NewPlayer()
		else:
			stream.write('i',0)
			stream.flush()
			raise Exception("The room was disbanded before the player could join.")
			return None

	try:
		stream.write('i',1)
		stream.flush()

		(sync_request,) = stream.read('i')
		if sync_request == 1:
			Synchronize(stream,player,room)
			stream.flush()
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
	5:ReceiveAction,#read iif, state, unique, time
	7:SendGameOverview,#writes 'ii' (state number and level)
	8:ReceiveFlagState,#reads iiffi state,flag,x,y, unique
	9:ReceiveWin,#reads ii state,team
	10:ReceiveDamage,#read iffiii, state, time, damage, target_id, target_unique, source_unique
	11:ReceiveChat,#read i64s, state, text
	12:StopFlushing,#not in use
	13:Flush,
	14:FlushButNotNow,#not in use


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
			print("A player has been lost, the error was:",str(error),"while processing the message:",message_id)
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

def RoomMaintenance():
	while True:
		reserved_rooms = set()
		with players_lock:
			for player_id in players:
				if ( time.time() - players[player_id].time ) > 300:
					del players[player_id]
				else:
					reserved_rooms.add(players[player_id].room_id)

		with rooms_lock:
			for room_id in rooms:
				if rooms[room_id].players == 0:
					if ( time.time() - rooms[room_id].time ) > 600:
						if room_id not in reserved_rooms:
							del rooms[room_id]

		time.sleep(180)




def MatchmakerWriter(stream):
	while True:
		stream.write('i',1)#send server state

		priority = 5 #todo, find under how much stress the server is, by magic
		#10-6 urgent
		#5-1 nomal
		#0 no more

		elapsed_time = time.time()

		with rooms_lock:
			temp_rooms = {}
			for room_id in rooms:
				with rooms[room_id].lock:
					temp_rooms[room_id] = len(rooms[room_id].players)
					if 0 < len(rooms[room_id].players) < 10:
						priority = 10

		elapsed_time = time.time() - elapsed_time
		print("Performance time is about:",elapsed_time)
		#todo, decrease priority based on elapsed_time

		stream.write('ii',priority,len(temp_rooms))
		for room_id in temp_rooms:
			stream.write('32si',room_id,temp_rooms[room_id])
			
		stream.flush()
		time.sleep(60)


def MatchmakerReader(stream):
	try:
		message_id = True
		while message_id:
			(message_id,) = stream.read('i')
			MatchmakerHandler[message_id](stream)
			stream.flush()
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
	stream.flush()
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

	room_maintenance_thread = threading.Thread(target = RoomMaintenance)
	room_maintenance_thread.daemon = True
	room_maintenance_thread.start()
