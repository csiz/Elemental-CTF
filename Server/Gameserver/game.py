import threading
import time

class Point:
	def __init__(self,x=0,y=0):
		self.x = x
		self.y = y

class Player:
	def __init__(self,id):
		self.id = id
		self.room_id = None
		self.points = 0

		#state information
		self.position = Point()
		self.projectiles = {}

class Projectile:
	position = Point()

class Flag:
	position = Point()




class GameRoom:
	#todo
	def __init__(self):
		self.players = {}
		self.flags = {
			"fire":Flag(),
			"water":Flag()
		}
		self.time = time.time()
		self.id_count = 1

		self.lock = threading.RLock()

		print("Created a new room")

	def AddPlayer(self,player):
		with self.lock:
			player.id = self.id_count
			self.id_count += 1
			self.players[player.id] = player

