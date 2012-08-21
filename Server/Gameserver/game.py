import threading
import time


class Player:
	def __init__(self,id):
		self.id = id

		#state information
		self.team = 0;
		self.time = 0 #time of update
		self.objects = []
		#incoming information
		self.actions = []

class Object:
	def __init__(self,unique,role,flavor,x,y,vx,vy,hp):
		self.unique = unique
		self.role = role
		self.flavor = flavor
		self.x = x
		self.y = y
		self.vx = vx
		self.vy = vy
		self.health = hp

class Action:
	def __init__(self,id,time):
		self.id = id
		self.time = time



class GameRoom:
	#todo
	def __init__(self):
		#state
		self.players = {}
		self.flags = {
			"fire":Object(1,"flag","flag fire",0,0,0,0,0),
			"water":Object(2,"flag","flag water",0,0,0,0,0)
		}

		self.time = time.time()
		self.id_count = 1
		self.lock = threading.RLock()
		print("Created a new room.")

	def NewPlayer(self):
		with self.lock:
			player = Player(self.id_count)
			self.id_count += 1
			self.players[player.id] = player
			return player

	def RemovePlayer(self,player):
		with self.lock:
			del self.players[player.id]


