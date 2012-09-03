import struct
import io
import time
import atexit
import pickle
import socket
import threading
import socketserver

import database
import matchmaker
from socketstream import *


def MessageDone(stream):
	pass

def CheckAvailability(stream):
	(id,) = stream.read('32s')
	result = database.ChecKAvailability(id)
	if(result):
		stream.write('i',1)
	else:
		stream.write('i',0)

def NewPlayer(stream):
	player = database.AddPlayer()
	stream.write('32s',player.id) #writes the id back

def CheckPlayer(stream):
	(id,password) = stream.read('32s32s')
	if database.Check(id,password):
		stream.write('i',1)
	else:
		stream.write('i',0)

def GetPlayer(stream):
	(id,password) = stream.read('32s32s')
	player = database.GetPlayer(id,password)
	if player == None:
		stream.write('i',0)#invalid login
	else:
		stream.write('i',1)#proceed
		
		#todo send everything from Player
		stream.write('32s256si', player.name, player.mail, player.points)

def ChangeName(stream):
	(id, password, name) = stream.read('32s32s32s')
	if database.ChangeName(id,password,name):
		stream.write('i',1)#success
	else:
		stream.write('i',0)#fail

def ChangeLogin(stream):
	(id, password, new_id, new_password) = stream.read('32s32s32s32s')
	if database.ChangeLogin(id, password, new_id, new_password):
		stream.write('i',1)
	else:
		stream.write('i',0)

def FindGame(stream):
	(id, password, region) = stream.read('32s32s32s')
	if database.Check(id,password):
		result = matchmaker.Find(id,region)
		if result:
			(address,port,room) = result
			stream.write('i32si32s',1,address,port,room)
		else:
			stream.write('i',2) #keep trying
	else:
		stream.write('i',0) #fail

def FindRoom(stream):
	(id, password, region, room_id) = stream.read('32s32s32s32s')
	if database.Check(id,password):
		result = matchmaker.FindRoom(id,room_id,region)
		if result:
			(address,port,room) = result
			stream.write('i32si32s',1,address,port,room)
		else:
			stream.write('i',2) #keep trying
	else:
		stream.write('i',0) #fail

###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
MessageHandler = {#reads, returns:
	0:MessageDone,#nothing
	1:CheckAvailability,
	#id
	#0 or 1

	2:NewPlayer,
	#nothing
	#id

	3:GetPlayer,
	#id, password
	#0 or 1; if(1){name32, mail256, points4} else{nothing}

	4:ChangeName,
	#id, password, name
	#0 or 1

	5:ChangeLogin,
	#id, password, new_id, new_password
	#0 or 1

	6:FindGame,
	#id, password, region
	#0 or 1 or 2, then address, port, room id

	7:FindRoom,
	#id, password, region, room_id
	#0 or 1 or 2, then address, port, room id

	8:CheckPlayer,
	#id, password
	#1 or 0

	#remember to also add in DDOS prevention below
}
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################

#DDOS prevention
MessageCost = {
	0:1,
	1:1,
	2:100,
	3:10,
	4:1,
	5:50,
	6:1,
	7:5,
	8:5,
}
CostCap = 3600
IPList = {}
def UpdateIP(ip, id):
	if ip in IPList:
		(current, last_updated) = IPList[ip]
		current -= (time.time() - last_updated)
		if current < 0:
			current = 0
		IPList[ip] = (current+MessageCost[id], time.time())
		if current > CostCap:
			raise Exception ("DDOS prevention blocked the ip: "+ip)
	else:
		IPList[ip] = (MessageCost[id], time.time())
#End DDOS prevention



class ThreadedTCPRequestHandler(socketserver.BaseRequestHandler):
	def handle(self):
		stream = SocketStream(self.request)
		print ("Received connection from {}:{}".format(self.client_address[0],self.client_address[1]))

		try:
			message_id = True
			while message_id:
				(message_id,) = stream.read('i')
				UpdateIP(self.client_address[0],message_id)
				MessageHandler[message_id](stream)
				print("Processed message:",message_id)
		except Exception as error:
			print("A socket has been lost, the error was:",str(error))
		finally:
			stream.close()
			print ("Ended connection from {}:{}".format(self.client_address[0],self.client_address[1]))
			

class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
	pass

class ServeForeverThread(threading.Thread):
	def run(self):
		HOST, PORT = '', 25971 #socket.gethostname(), 25971
		self.server = ThreadedTCPServer((HOST, PORT), ThreadedTCPRequestHandler)
		print ("Server listening on:",HOST,":",PORT," , in thread:",self.name)
		self.server.serve_forever()

	def stop(self):
		self.server.shutdown()
		print("Server has been shutdown.")

def LoadData():
	with open('database.pk', 'rb') as input:
		with database.data_lock:
			database.data = pickle.load(input)

def SaveData():
	with open('database.pk', 'wb') as output:
		with database.data_lock:
			pickle.dump(database.data, output, pickle.HIGHEST_PROTOCOL)


if __name__ == "__main__":
	#LoadData()
	#atexit.register(SaveData)
	

	#start matchmaker
	matchmaker.server_thread = matchmaker.ServeForeverThread()
	matchmaker.server_thread.start()

	#start player server
	server_thread = ServeForeverThread()
	server_thread.start()

	while(True):
		time.sleep(60)
		with database.history_lock:
			database.history.flush()
			print("Flushed history.")
