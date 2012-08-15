import time
import hashlib
import random
import threading

if __name__ == "__main__":
	print("database.py is not supposed to be run as main.")
	time.sleep(3)
	quit()

#import mailing

class Player():
	def __init__(self, id):
		self.id = id
		self.password = hashlib.sha256(id).digest()
		self.name = b''
		self.mail = b''
		self.points = 0
		

data = {}
data_lock = threading.RLock()

history = open("database.log","a")
history_lock = threading.RLock()

def AddPlayer():
	data_lock.acquire()

	id = str(random.randrange(1, 2**31 - 1)).encode()
	for i in range(len(id),32):
		id += b'\x00'
	while id in data:
		id = str(random.randrange(1, 2**31 - 1)).encode()
		for i in range(len(id),32):
			id += b'\x00'

	player = Player(id)
	data[id] = player
	data_lock.release()

	history_lock.acquire()
	print("Added ID:",player.id,player.password,".\n",file = history)
	history_lock.release()


	return player

def CheckAvailability(id):
	data_lock.acquire()
	response = id not in data
	data_lock.release()

	return response

def Check(id, password):
	data_lock.acquire()
	response = None
	if id in data:
		response = (password == data[id].password)
	else:
		response = False
	data_lock.release()

	return response


def ChangeName(id, password, name):
	data_lock.acquire()
	response = None
	if Check(id,password):
		data[id].name = name
		response = True
	else:
		response = False
	data_lock.release()

	history_lock.acquire()
	print("ID:",id,"changed name to:",name,".\n",file = history)
	history_lock.release()

	return response

def ChangeLogin(id, password, new_id, new_password):
	data_lock.acquire()
	response = None
	if Check(id,password):
		if id == new_id:
			data[id].password = new_password
			response = True
			try:
				mailing.Send(data[new_id].mail, "Password succesfuly changed.")
			except:
				print("Couldn't send mail.")
		else:
			if CheckAvailability(new_id):
				data[new_id] = data[id]
				del data[id]
				data[new_id].id = new_id
				data[new_id].password = new_password

				history_lock.acquire()
				print("ID:",id,"changed login to:",new_id,new_password,".\n",file = history)
				history_lock.release()

				response = True
				try:
					mailing.Send(data[new_id].mail, "Login information succesfuly changed. Your new id is: " + data[new_id].id)
				except:
					print("Couldn't send mail.")
			else:
				response = False
	else:
		response = False
	data_lock.release()

	return response

def GetPlayer(id, password):
	player = None
	data_lock.acquire()
	if Check(id, password):
		player = data[id]
	data_lock.release()

	return player






