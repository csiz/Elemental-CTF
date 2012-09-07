package code.game {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	
	public class UI extends MovieClip {
		public var game:Game;
		public var chat_frames = 600;
		public var score_board = new MovieClip();
		
		public function UI(game:Game) {
			this.game = game
			chose_player_dialog.melee_fire.addEventListener(MouseEvent.CLICK,function(event){FinishPlayerSelect("melee fire","melee");});
			chose_player_dialog.melee_water.addEventListener(MouseEvent.CLICK,function(event){FinishPlayerSelect("melee water","melee");});
			chose_player_dialog.ranged_fire.addEventListener(MouseEvent.CLICK,function(event){FinishPlayerSelect("ranged fire","ranged");});
			chose_player_dialog.ranged_water.addEventListener(MouseEvent.CLICK,function(event){FinishPlayerSelect("ranged water","ranged");});
			chose_player_dialog.visible = false;
			overview_dialog.visible = false;
			
			overview_dialog.menu_button.addEventListener(MouseEvent.CLICK,function(event){game.End();});
			
			chat_input.visible = false;
			chat_input.addEventListener(FocusEvent.FOCUS_OUT, function(event){game.chatting = false;chat_input.visible = false;chat_frames = 600;});
			chat_input.addEventListener(FocusEvent.FOCUS_IN, function(event){game.chatting = true;chat_input.visible = true;});
			chat_input.addEventListener(KeyboardEvent.KEY_DOWN,WriteChat);
			
			addEventListener(Event.ENTER_FRAME, ChatVisibility);
			overview_dialog.score_scroll_pane.source = score_board;
			overview_dialog.score_scroll_pane.focusRect = false;
			addEventListener(Event.ENTER_FRAME, ScoreUpdater);
			
			
		}
		
		public function ScoreUpdater(event){
			score_board.removeChildren();
			var sy = 0;
			var objs = game.network.objects;
			for(var i in objs){
				var text_field = new TextField();
				text_field.y = sy;
				text_field.x = 20;
				sy += 25;
				text_field.text = i.toString() + ": " + objs[i].role + " " + objs[i].body.GetPosition().x.toFixed(0) + ", " + objs[i].body.GetPosition().y.toFixed(0);
				text_field.width = 320;
				text_field.selectable = false;
				score_board.addChild(text_field);
			}
			overview_dialog.score_scroll_pane.update()
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
		public function WriteChat(event:KeyboardEvent){
			if(event.charCode == Keyboard.ENTER){
				if(chat_input.text.length > 0){
					game.network.WriteChat(chat_input.text);
					chat_input.text = "";
				}
			}
		}
		public function ChatLine(s:String){
			chat.appendText("\n" + s);
			chat.scrollV = chat.numLines;
			chat_frames = Math.max(300,chat_frames);
		}
		public function ChatVisibility(event){
			chat_frames --;
			chat_frames = Math.max(chat_frames,0);
			
			if(game.chatting){
				chat.alpha = 1;
			}else{
				chat.alpha = Math.min(1,chat_frames/120);
			}
		}
	}
	
}
