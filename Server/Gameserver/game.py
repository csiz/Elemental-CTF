import threading
import time


class Player:
	def __init__(self,id):
		self.id = id

		#state information
		self.win = False
		self.team = 0
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
	def __init__(self,unique,time):
		self.unique = unique
		self.time = time



class GameRoom:
	#todo
	def __init__(self):
		self.lock = threading.RLock()
		#state
		self.state_number = 0
		self.time = time.time()
		self.id_count = 1
		self.level = 0
		self.win = 0
		#entities
		self.players = {}
		self.flags = {}
		print("Created a new room.")
		self.NewLevel()

	def NewLevel(self,lvl = None):
		if lvl == None:#todo, select a random lvl from the level pool
			lvl = 0

		with self.lock:
			#entities reset
			self.flags = {
				1:Object(0,None,None,0,0,None,None,None),#fire flag
				2:Object(0,None,None,0,0,None,None,None)#water flag
			}#unique is the carrier or 0 if its origin or -1 if its floating, x and y are the positions if its floating
			for id in self.players:
				self.players[id].__init__(id)

			#new state
			self.state_number += 1
			self.level = lvl
			self.win = 0

	def Win(self,team):
		if not self.win:
			self.win = team
			new_level_thread = threading.Thread(target = self.NewLevelTimeout)
			new_level_thread.daemon = True
			new_level_thread.start()
			


	def NewPlayer(self):
		with self.lock:
			player = Player(self.id_count)
			self.id_count += 1
			self.players[player.id] = player
			return player

	def RemovePlayer(self,player):
		with self.lock:
			del self.players[player.id]


	def NewLevelTimeout(self):
		time.sleep(30)
		self.NewLevel()