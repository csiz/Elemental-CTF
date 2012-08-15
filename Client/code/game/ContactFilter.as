package code.game{
	import Box2D.Dynamics.*;
	
	public class ContactFilter extends b2ContactFilter{
		public function ContactFilter(){}
		public override function ShouldCollide(fixtureA:b2Fixture, fixtureB:b2Fixture):Boolean{
			if(fixtureA.GetBody().GetUserData()){
				if(fixtureB.GetBody().GetUserData()){
					if(fixtureA.GetBody().GetUserData().role == "player"){
						if(fixtureB.GetBody().GetUserData().role == "player"){
							if(fixtureB.GetBody().GetUserData().team == fixtureA.GetBody().GetUserData().team){
								return false;
							}
						}
						if(fixtureB.GetBody().GetUserData().role == "projectile"){
							if(fixtureB.GetBody().GetUserData().team == fixtureA.GetBody().GetUserData().team){
								return false;
							}
						}
					}
					if(fixtureB.GetBody().GetUserData().role == "player"){
						if(fixtureA.GetBody().GetUserData().role == "projectile"){
							if(fixtureB.GetBody().GetUserData().team == fixtureA.GetBody().GetUserData().team){
								return false;
							}
						}
					}
					if(fixtureA.GetBody().GetUserData().role == "projectile"){
						if(fixtureB.GetBody().GetUserData().role == "projectile"){
							if(fixtureB.GetBody().GetUserData().flavor == "projectile water" && fixtureA.GetBody().GetUserData().flavor == "projectile water"){
								return true;
							}
							if(fixtureB.GetBody().GetUserData().team == fixtureA.GetBody().GetUserData().team){
								return false;
							}
						}
					}
				}
			}
			return true;
		}
	}
}