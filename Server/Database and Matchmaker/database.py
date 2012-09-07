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
	with data_lock:

		id = str(random.randrange(1, 2**31 - 1)).encode()
		for i in range(len(id),32):
			id += b'\x00'
		while id in data:
			id = str(random.randrange(1, 2**31 - 1)).encode()
			for i in range(len(id),32):
				id += b'\x00'

		player = Player(id)
		data[id] = player

	with history_lock:
		print("Added ID:",player.id,player.password,".\n",file = history)


	return player

def CheckAvailability(id):
	with data_lock:
		response = id not in data

	return response

def GetName(id):
	with data_lock:
		if id in data:
			return data[id].name
		else:
			return None

def Check(id, password):
	with data_lock:
		response = None
		if id in data:
			response = (password == data[id].password)
		else:
			response = False

	return response


def ChangeName(id, password, name):
	with data_lock:
		response = None
		if Check(id,password):
			data[id].name = name
			response = True
		else:
			response = False

	with history_lock:
		print("ID:",id,"changed name to:",name,".\n",file = history)
	

	return response

def ChangeEmail(id, password, email):
	with data_lock:
		response = None
		if Check(id,password):
			data[id].mail = email
			response = True
		else:
			response = False

	with history_lock:
		print("ID:",id,"changed email to:",email,".\n",file = history)
	

	return response

def ChangeLogin(id, password, new_id, new_password):
	with data_lock:
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

					with history_lock:
						print("ID:",id,"changed login to:",new_id,new_password,".\n",file = history)

					response = True
					try:
						mailing.Send(data[new_id].mail, "Login information succesfuly changed. Your new id is: " + data[new_id].id)
					except:
						print("Couldn't send mail.")
				else:
					response = False
		else:
			response = False


	return response

def GetPlayer(id, password):
	player = None
	with data_lock:
		if Check(id, password):
			player = data[id]

	return player






