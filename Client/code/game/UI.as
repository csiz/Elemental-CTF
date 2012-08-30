package code.game {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	
	public class UI extends MovieClip {
		public var game:Game;
		
		public function UI(game:Game) {
			this.game = game
			chose_player_dialog.melee_fire.addEventListener(MouseEvent.CLICK,function(){FinishPlayerSelect("melee fire","melee");});
			chose_player_dialog.melee_water.addEventListener(MouseEvent.CLICK,function(){FinishPlayerSelect("melee water","melee");});
			chose_player_dialog.ranged_fire.addEventListener(MouseEvent.CLICK,function(){FinishPlayerSelect("ranged fire","ranged");});
			chose_player_dialog.ranged_water.addEventListener(MouseEvent.CLICK,function(){FinishPlayerSelect("ranged water","ranged");});
			chose_player_dialog.visible = false;
			overview_dialog.visible = false;
		}
		
		public function StartPlayerSelect(){
			chose_player_dialog.visible = true;
			
		}
		private function FinishPlayerSelect(flavor:String,type:String){
			game.Ready = function (){game.Spawn(flavor,type);};
			chose_player_dialog.visible = false;
		}
		public function CancelPlayerSelect(){
			chose_player_dialog.visible = false;
		}
		
		public function ShowOverview(){
			overview_dialog.visible = true;
		}
		public function HideOverview(){
			overview_dialog.visible = false;
		}
	}
	
}
