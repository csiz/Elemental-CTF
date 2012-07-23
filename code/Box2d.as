﻿package code
{
	import Box2D.Collision.*;
	import Box2D.Common.Math.*;
	import Box2D.Collision.Shapes.*
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*
	
	
	import flash.display.MovieClip;
	import flashx.textLayout.events.ModelChange;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	
	public class Box2d
	{
		public var levels:Levels;
		public var movie:MovieClip;
		public var game:Game;
		
		public var m_world:b2World;
		public var m_iterations:int = 10;
		
		public var update_list:Dictionary;
		
		public function Box2d(lvls:Levels,mov:MovieClip,game:Game)
		{
			levels = lvls;
			movie = mov;
			this.game = game;
			update_list = new Dictionary(true);
			
			// Define the gravity vector
			var gravity:b2Vec2 = new b2Vec2(0.0, 30.0);
				
			// Allow bodies to sleep
			var doSleep:Boolean = true;
			
			// Construct a world object
			m_world = new b2World(gravity, doSleep);
			m_world.SetContactFilter(new ContactFilter());
			
			
			// set debug draw
			var dbgDraw:b2DebugDraw = new b2DebugDraw();
			dbgDraw.SetSprite(movie);
			dbgDraw.SetDrawScale(20.0);
			dbgDraw.SetFillAlpha(0.5);
		 	dbgDraw.SetLineThickness(1.0);
			dbgDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			m_world.SetDebugDraw(dbgDraw);
		}
		
		public function LoadLevel(lvl:int)
		{
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var boxDef:b2FixtureDef;
			
			for(var y = 0;y < levels.level[lvl].height;y++)
			{
				for(var x = 0;x < levels.level[lvl].width;x++)
				{
					var yes:Boolean = true;
					//general
					bodyDef = new b2BodyDef();
					bodyDef.position.Set(x, y);
					boxDef = new b2FixtureDef();
					boxDef.density = 0;
					bodyDef.type = b2Body.b2_staticBody;
					//properties
					switch ( levels.GetType(lvl, x, y) )
					{
						case "brick":
						boxDef.friction = 0.3;
						boxDef.restitution = 0;
						bodyDef.userData = new Brick();
						break;
						//end brick
						case "bouncy":
						boxDef.friction = 0.3;
						boxDef.restitution = 0.5;
						bodyDef.userData = new Bouncy();
						break;
						//end bouncy
						default:
						yes = false;
						break;
					}
					if(yes){//did we find a brick?
						//shape
						switch( levels.GetOrientation(lvl, x, y) )
						{
							case "NE":
							boxDef.shape = b2PolygonShape.AsArray(
								[new b2Vec2(-0.5,-0.5),
								 new b2Vec2(0.5,0.5),
								 new b2Vec2(-0.5,0.5)],
								 3);
							boxDef.userData = {role:"brick NE"};
							bodyDef.userData.gotoAndStop("NE");
							break;
							case "SE":
							boxDef.shape = b2PolygonShape.AsArray(
								[new b2Vec2(-0.5,-0.5),
								 new b2Vec2(0.5,-0.5),
								 new b2Vec2(-0.5,0.5)],
								 3);
							bodyDef.userData.gotoAndStop("SE");
							break;
							case "NW":
							boxDef.shape = b2PolygonShape.AsArray(
								[new b2Vec2(0.5,-0.5),
								 new b2Vec2(0.5,0.5),
								 new b2Vec2(-0.5,0.5)],
								 3);
							boxDef.userData = {role:"brick NW"};
							bodyDef.userData.gotoAndStop("NW");
							break;
							case "SW":
							boxDef.shape = b2PolygonShape.AsArray(
								[new b2Vec2(-0.5,-0.5),
								 new b2Vec2(0.5,-0.5),
								 new b2Vec2(0.5,0.5)],
								 3);
							bodyDef.userData.gotoAndStop("SW");
							break;
							case "normal":
							default:
							boxDef.shape = b2PolygonShape.AsBox(0.5, 0.5);
							break;
						}
						//other
						bodyDef.userData.x = 20 * x;
						bodyDef.userData.y = 20 * y;
						movie.addChild(bodyDef.userData);
						//add it
						body = m_world.CreateBody(bodyDef);
						body.CreateFixture(boxDef);
					}
				}
			}
		}
		
		public function AddPlayer(pos:Point, flavor:String):Player
		{
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var fixtureDef:b2FixtureDef;
			var circleShape:b2CircleShape;
			
			bodyDef = new b2BodyDef();
			bodyDef.position.x = pos.x;
			bodyDef.position.y = pos.y;
			bodyDef.fixedRotation = true;
			bodyDef.type = b2Body.b2_dynamicBody;
			body = m_world.CreateBody(bodyDef);
			body.SetLinearDamping(0.3);
			
			switch (flavor)
			{
				case "melee fire":
				//create the player:
				fixtureDef = new b2FixtureDef();
				fixtureDef.shape = new b2CircleShape(0.98);
				fixtureDef.friction = 0.3;
				fixtureDef.restitution = 0.2;
				fixtureDef.density = 1;
				body.CreateFixture(fixtureDef);

				//create foot sensor:
				fixtureDef = new b2FixtureDef();
				circleShape = new b2CircleShape();
				circleShape.SetRadius(0.9);
				circleShape.SetLocalPosition(new b2Vec2(0,0.3));
				fixtureDef.shape = circleShape;
				fixtureDef.density = 0;
				fixtureDef.isSensor = true;
				fixtureDef.userData = {role:"player foot"}
				body.CreateFixture(fixtureDef);
				
				//slippery head:
				fixtureDef = new b2FixtureDef();
				circleShape = new b2CircleShape();
				circleShape.SetRadius(0.99);
				circleShape.SetLocalPosition(new b2Vec2(0,-0.02));
				fixtureDef.shape = circleShape;
				fixtureDef.density = 0;
				fixtureDef.friction = 0.1;
				fixtureDef.restitution = 0.1;
				body.CreateFixture(fixtureDef);

				break;
				//melee fire
				
				
				case "melee water":
				//create the player:
				fixtureDef = new b2FixtureDef();
				fixtureDef.shape = new b2CircleShape(0.98);
				fixtureDef.friction = 0.3;
				fixtureDef.restitution = 0.2;
				fixtureDef.density = 1;
				body.CreateFixture(fixtureDef);

				//create foot sensor:
				fixtureDef = new b2FixtureDef();
				circleShape = new b2CircleShape();
				circleShape.SetRadius(0.9);
				circleShape.SetLocalPosition(new b2Vec2(0,0.3));
				fixtureDef.shape = circleShape;
				fixtureDef.density = 0;
				fixtureDef.isSensor = true;
				fixtureDef.userData = {role:"player foot"}
				body.CreateFixture(fixtureDef);
				
				//slippery head:
				fixtureDef = new b2FixtureDef();
				circleShape = new b2CircleShape();
				circleShape.SetRadius(0.99);
				circleShape.SetLocalPosition(new b2Vec2(0,-0.02));
				fixtureDef.shape = circleShape;
				fixtureDef.density = 0;
				fixtureDef.friction = 0.1;
				fixtureDef.restitution = 0.1;
				body.CreateFixture(fixtureDef);

				break;
				//melee water
				
				
				case "ranged fire":
				//create the player:
				fixtureDef = new b2FixtureDef();
				fixtureDef.shape = new b2CircleShape(0.73);
				fixtureDef.friction = 0.3;
				fixtureDef.restitution = 0.2;
				fixtureDef.density = 1;
				body.CreateFixture(fixtureDef);

				//create foot sensor:
				fixtureDef = new b2FixtureDef();
				circleShape = new b2CircleShape();
				circleShape.SetRadius(0.65);
				circleShape.SetLocalPosition(new b2Vec2(0,0.3));
				fixtureDef.shape = circleShape;
				fixtureDef.density = 0;
				fixtureDef.isSensor = true;
				fixtureDef.userData = {role:"player foot"}
				body.CreateFixture(fixtureDef);
				
				//slippery head:
				fixtureDef = new b2FixtureDef();
				circleShape = new b2CircleShape();
				circleShape.SetRadius(0.74);
				circleShape.SetLocalPosition(new b2Vec2(0,-0.02));
				fixtureDef.shape = circleShape;
				fixtureDef.density = 0;
				fixtureDef.friction = 0.1;
				fixtureDef.restitution = 0.1;
				body.CreateFixture(fixtureDef);

				break;
				//ranged fire
				
				default:
				trace("No player of type: "+flavor);
			}
			body.SetUserData(new Player(body,flavor,game));
			update_list[body] = body.GetUserData().sprite;
			game.player_list[body] = body.GetUserData();
			movie.addChild(body.GetUserData().sprite);
			return body.GetUserData();
			
		}
		public function AddProjectile(pos:Point, vel:Point, flavor:String):Projectile{
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var fixtureDef:b2FixtureDef;
			var circleShape:b2CircleShape;
			
			bodyDef = new b2BodyDef();
			bodyDef.position.x = pos.x;
			bodyDef.position.y = pos.y;
			bodyDef.linearVelocity.x = vel.x;
			bodyDef.linearVelocity.y = vel.y;
			
			bodyDef.type = b2Body.b2_dynamicBody;
			bodyDef.bullet = true;
			body = m_world.CreateBody(bodyDef);
			
			switch (flavor)
			{
				case "projectile fire":
				//create the player:
				fixtureDef = new b2FixtureDef();
				fixtureDef.shape = new b2CircleShape(0.25);
				fixtureDef.friction = 0;
				fixtureDef.restitution = 1;
				fixtureDef.density = 1;
				body.CreateFixture(fixtureDef);

				break;
				//projectile fire
				
				default:
				trace("No projectile of type: "+flavor);
			}
			body.SetUserData(new Projectile(body,flavor,game));
			update_list[body] = body.GetUserData().sprite;
			game.projectile_list[body] = body.GetUserData();
			movie.addChild(body.GetUserData().sprite);
			return body.GetUserData();
		}
		
		public function Update(timeStep:Number)
		{
			m_world.Step(timeStep * 0.001, m_iterations,m_iterations);
			m_world.ClearForces() ;
			//m_world.DrawDebugData();
			var body:*;
			for(body in update_list){
				if(update_list[body]){
					update_list[body].x = 20 * body.GetPosition().x;
					update_list[body].y = 20 * body.GetPosition().y;
				}
			}
			var contactEdge:b2ContactEdge;
			var contact:b2Contact;
			//ground check
			for(body in game.player_list)
			{
				if(game.player_list[body]){
					if(!game.player_list[body].ground){
						game.player_list[body].airSince += timeStep;
					}
					game.player_list[body].ground = false;
					body.SetLinearDamping(0.3);
					game.player_list[body].NE = false;
					game.player_list[body].NW = false;
					
					contactEdge = body.GetContactList();
					while(contactEdge){
						contact = contactEdge.contact;
						if(contact.IsTouching()){
							if(contact.GetFixtureA().GetUserData()){
								if(contact.GetFixtureA().GetUserData().role == "player foot"){
									contact.GetFixtureA().GetBody().GetUserData().ground = true;
									body.SetLinearDamping(2);
									contact.GetFixtureA().GetBody().GetUserData().airSince = 0;
									if(contact.GetFixtureB().GetUserData()){
										if(contact.GetFixtureB().GetUserData().role == "brick NE"){
											contact.GetFixtureA().GetBody().GetUserData().NE = true;
										}
										if(contact.GetFixtureB().GetUserData().role == "brick NW"){
											contact.GetFixtureA().GetBody().GetUserData().NW = true;
										}
									}
								}
							}
							//2
							if(contact.GetFixtureB().GetUserData()){
								if(contact.GetFixtureB().GetUserData().role == "player foot"){
									contact.GetFixtureB().GetBody().GetUserData().ground = true;
									body.SetLinearDamping(2);
									contact.GetFixtureB().GetBody().GetUserData().airSince = 0;
									if(contact.GetFixtureA().GetUserData()){
										if(contact.GetFixtureA().GetUserData().role == "brick NE"){
											contact.GetFixtureB().GetBody().GetUserData().NE = true;
										}
										if(contact.GetFixtureA().GetUserData().role == "brick NW"){
											contact.GetFixtureB().GetBody().GetUserData().NW = true;
										}
									}
								}
							}
						}
						contactEdge = contactEdge.next;
					}
				}
			}
			//end ground check
			//projectile hits count
			for(body in game.projectile_list){
				if(game.projectile_list[body]){
					contactEdge = body.GetContactList();
					while(contactEdge){
						contact = contactEdge.contact;
						if(contact.IsTouching()){
							body.GetUserData().hits++;
						}
						contactEdge = contactEdge.next;
					}
					
					if(body.GetUserData().hits > 3){
						movie.removeChild(update_list[body]);
						delete update_list[body];
						delete game.projectile_list[body];
						m_world.DestroyBody(body);
					}
				}
			}
			//end projectile hits count
		}
		//end update
	}
	//end class
}