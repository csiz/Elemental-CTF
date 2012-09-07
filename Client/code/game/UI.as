package code.game {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import code.User;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	public class UI extends MovieClip {
		public var game:Game;
		public var chat_frames = 600;
		public var score_board = new MovieClip();
		public var score_elements = new Dictionary(true);
		public var update_less = 0;
		
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
			if(update_less == 0){
				update_less = 60;
				var current_y = 10;
				var users = game.users;
				for(var id in score_elements){
					if(score_elements[id]){
						score_elements[id].mark = false;
					}
				}
				
				for(id in users){
					if(users[id]){
						if(!(score_elements[id])){
							score_elements[id] = new ScoreBoardEntry();
							score_board.addChild(score_elements[id]);
						}
						var element = score_elements[id]
						element.mark = true;
						//start chat row them:
						element.y = current_y;
					
						
						if(users[id].display_name != ""){
							element.pname.text = users[id].display_name;
						}else{
							element.pname.text = id.toString();
						}
						element.score.text = users[id].points.toString();
						
						if(users[id].chat != ""){
							element.chat.text = users[id].chat.slice(0,15);
						}else{
							element.chat.text = "Did not chat.";
						}
						
						//chat_field
						current_y += 25;
					}
				}
				for(id in score_elements){
					if(score_elements[id]){
						if(score_elements[id].mark == false){
							score_board.removeChild(score_elements[id]);
							delete score_elements[id];
						}
					}
				}
				
				overview_dialog.score_scroll_pane.update();
			}else{
				update_less --;
			}
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
		public function PlayerChat(id:int,txt:String){
			if(!(game.users[id])){
				game.users[id] = new User();
			}
			game.users[id].chat = txt;
			if(game.users[id].display_name != ""){
				ChatLine(game.users[id].display_name + ": " + txt);
			}else{
				ChatLine(id.toString() + ": " + txt);
			}
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

import flash.display.MovieClip;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
class ScoreBoardEntry extends MovieClip{
	public var pname = new TextField();
	public var score = new TextField();
	public var chat = new TextField();
	public var mark = true;
	
	public function ScoreBoardEntry(){
		pname.x = 20;
		pname.width = 70;
		pname.height = 25;
		pname.selectable = false;
		pname.multiline = false;
		addChild(pname);
		
		var score_format:TextFormat = new TextFormat();
		score_format.align = TextFormatAlign.RIGHT;
		
		score.defaultTextFormat = score_format;
		score.x = 130;
		score.width = 50;
		score.height = 25;
		score.multiline = false;
		score.selectable = false;
		addChild(score);
		
		chat.x = 200;
		chat.width = 70;
		chat.height = 25;
		chat.multiline = false;
		chat.selectable = false;
		addChild(chat);
	}
}