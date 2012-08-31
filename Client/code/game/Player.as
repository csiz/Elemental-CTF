package code.game
{
	import flash.display.MovieClip;
	import Box2D.Dynamics.b2Body;
	import flash.geom.Point;
	import Box2D.Common.Math.b2Vec2;
	import code.game.players.*;

	public class Player{
		public var game:Game;
		public var sprite:PlayerAnimate;
		public var flavor:String;
		public var body:b2Body;
		public var id:int;
		public var unique:int;
		public var speed:Number;
		public var airSpeed:Number;
		public var jump:Number;
		public var ground:Boolean;
		public var airSince:Number;
		public var actionSince:Number;
		public var upwards:Number;
		public var downwards:Number;
		public var uphill:Number;
		public var downhill:Number;
		public var NE:Boolean;
		public var NW:Boolean;
		public var cooldown:Number;
		public var power:Number;
		public var role:String;
		public var team:String;
		public var health:Number;
		public var maxHealth:Number;
		public var attack:Number;
		public var attackTimer:Number;
		public var energy:Number;
		public var energy_cost:Number;
		public var energy_regen:Number;
		public var deathTimer:Number;
		public var alive:Boolean;
		public var regen:Number;
		public var flag:Flag;
		public var removed:Boolean;
		public var hitTimer:Number;
		
		public function Player(body:b2Body, flavor:String, id:int, unique:int, game:Game)
		{
			this.id = id;
			this.unique = unique;
			this.game = game;
			flag = null;
			removed = false;
			
			role = "player";
			
			this.flavor = flavor;
			this.body = body;
			ground = false;
			NE = false;
			NW = false;
			airSince = 5000;
			actionSince = 5000;
			attackTimer = 0;
			hitTimer = 0;
			deathTimer = 0;
			energy = 0;
			energy_regen = 10;
			alive = true;
			switch (flavor)
			{
				case "melee fire":
				team = "fire";
				health = 301;
				maxHealth = 301;
				regen = 10;
				attack = 100;
				sprite = new PlayerMeleeFire(this);
				speed = 1;
				airSpeed = 0.3;
				jump = 1.6;//6 units with boost, 5 without
				upwards = 0.1;
				uphill = 1;
				downhill = 0.3;
				downwards = 1;
				
				cooldown = 4000;
				energy_cost = 50;
				power = 35;
				break;
				//melee fire
				
				case "melee water":
				team = "water";
				health = 301;
				maxHealth = 301;
				regen = 10;
				attack = 100;
				sprite = new PlayerMeleeWater(this);
				speed = 0.8;
				airSpeed = 0.2;
				jump = 1.6;//6 units with boost, 5 without
				upwards = 0.1;
				uphill = 0.8;
				downhill = 0.3;
				downwards = 2;
				
				cooldown = 1000;
				energy_cost = 30;
				power = 20;
				break;
				//melee water
				
				case "ranged fire":
				team = "fire";
				health = 100;
				maxHealth = 100;
				regen = 10;
				attack = 60;
				sprite = new PlayerRangedFire(this);
				speed = 0.6;
				airSpeed = 0.1;
				jump = 1.33;//5 units with boost, 4 without
				upwards = 0.1;
				uphill = 0.6;
				downhill = 0.3;
				downwards = 1;
				
				cooldown = 500;
				energy_cost = 20;
				power = 30;
				break;
				//ranged fire
				
				case "ranged water":
				team = "water";
				health = 100;
				maxHealth = 100;
				regen = 10;
				attack = 60;
				sprite = new PlayerRangedWater(this);
				speed = 0.6;
				airSpeed = 0.1;
				jump = 1.33;//5 units with boost, 4 without
				upwards = 0.1;
				uphill = 0.6;
				downhill = 0.3;
				downwards = 1;
				
				cooldown = 150;//here
				energy_cost = 10;
				power = 25;
				break;
				//ranged fire
				
				default:
				trace("You wanted: "+flavor+". But that's not an option anymore");
				//remember to add to Network flavor_map
				//and in Game.Add
			}
			
			sprite.x = 20 * body.GetPosition().x;
			sprite.y = 20 * body.GetPosition().y;
			game.movie.addChild(sprite);
			game.network.Add(this);
		}
		public function Right(timeStep:Number)
		{
			if(alive){
				if(ground)
				{
					if(NW){
						body.ApplyImpulse(new b2Vec2(speed * body.GetMass() * timeStep * 0.06, -uphill * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
					}else if(NE){
						body.ApplyImpulse(new b2Vec2(speed * body.GetMass() * timeStep * 0.06, +downhill * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
					}else{
						body.ApplyImpulse(new b2Vec2(speed * body.GetMass() * timeStep * 0.06, -upwards * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
					}
				}else{
					body.ApplyImpulse(new b2Vec2(airSpeed * body.GetMass() * timeStep * 0.06, 0),new b2Vec2(0, 0))
				}
			}
		}
		public function Left(timeStep:Number)
		{
			if(alive){
				if(ground)
				{
					if(NE){
						body.ApplyImpulse(new b2Vec2(-speed * body.GetMass() * timeStep * 0.06, -uphill * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
					}else if(NW){
						body.ApplyImpulse(new b2Vec2(-speed * body.GetMass() * timeStep * 0.06, +downhill * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
					}else{
						body.ApplyImpulse(new b2Vec2(-speed * body.GetMass() * timeStep * 0.06, -upwards * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
					}
				}else{
					body.ApplyImpulse(new b2Vec2(-airSpeed * body.GetMass() * timeStep * 0.06, 0),new b2Vec2(0, 0));
				}
			}
		}
		public function Jump(timeStep:Number)
		{
			if(alive){
				if(airSince < 160)
				{
					body.ApplyImpulse(new b2Vec2(0, -jump * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
				}
			}
		}
		public function Down(timeStep:Number){
			if(alive){
				if(ground){
					body.ApplyImpulse(new b2Vec2(0, downwards * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
				}
			}
		}
		public function Action(x:Number, y:Number){
			if(alive){
				var l = Math.sqrt(x*x + y*y);
				if(l==0){
					l=1;//no divide by 0 errors
				}
				if(energy >= energy_cost){
					if(actionSince > cooldown){
						actionSince = 0;
						energy -= energy_cost;
						game.network.Action(game.state_number,this.id);
						switch (flavor)
						{
							case "melee fire":
							body.ApplyImpulse(new b2Vec2(power * x/l * body.GetMass(), power * y/l * body.GetMass() ),new b2Vec2(0, 0));
							break;
							//melee fire
							case "melee water":
							body.ApplyImpulse(new b2Vec2(power * x/l * body.GetMass(), power * y/l * body.GetMass() ),new b2Vec2(0, 0));
							break;
							//melee water
							case "ranged fire":
							game.box2d.AddProjectile(new Point(body.GetPosition().x,body.GetPosition().y),new Point(power * x/l + body.GetLinearVelocity().x, power * y/l + body.GetLinearVelocity().y), "projectile fire",id);
							break;
							//ranged fire
							case "ranged water":
							game.box2d.AddProjectile(new Point(body.GetPosition().x,body.GetPosition().y),new Point(power * x/l + body.GetLinearVelocity().x, power * y/l + body.GetLinearVelocity().y), "projectile water",id);
							break;
							//ranged fire
							
							default:
							trace("No ability for "+flavor+" yet.");
						}
						sprite.Action(0);
					}
				}
			}
		}
		public function Remove(){
			if(!removed){
				if(flag){
					flag.Drop();
				}
				game.movie.removeChild(sprite);
				game.box2d.m_world.DestroyBody(body);
				delete game.box2d.update_list[body];
				delete game.player_list[body];
				game.network.Remove(unique);
				removed = true;
			}
		}
		public function Update(timeStep:Number){
			actionSince += timeStep;
			attackTimer +=timeStep;
			hitTimer += timeStep;
			if(!alive){
				deathTimer += timeStep;
				if(deathTimer > 5000){
					Remove();
				}
			}
			if(alive){
				energy += energy_regen * timeStep/1000;
				energy = Math.min(energy,100);
				
				health += regen * timeStep/1000;
				health = Math.min(maxHealth,health);
			}
			sprite.Update(timeStep);
		}
		public function Attack(damage:Number, id:int){
			if(hitTimer > 50){//to exclude double attacks and such, this may present some problems later
				health -= damage;
				if(health <= 0){
					Kill();
				}
			}
		}
		public function Kill(delay:Number = 0){
			if(alive){
				sprite.Kill(delay);
				if(flag){
					flag.Drop();
				}
				alive = false;
				deathTimer = delay;
				health = 0;
			}
		}
	}
}