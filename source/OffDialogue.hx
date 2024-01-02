package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import states.*;
import ui.*;
using StringTools;
enum Position{
    Upper;
    Bottom;
}
class OffDialogue extends FlxSpriteGroup
{
    public var box:FlxSprite;
	var curCharacter:String = 'batter';
	var offTextt:FlxTypeText;
	var curLine:Int = 0;
	public var finishThing:Void->Void;

    public var appearBatter:Void->Void;
    var dialogue:Array<String>=[];
    var portrait:FlxSprite;
    var dialogueIndicator:FlxSprite;
    var narrator:Bool = false;
    public function new(dialogue:Array<String>, ?position:Position = Upper, ?narrator:Bool = false){
        super();
        switch(position){
            case Upper:
                this.y = 0;
            case Bottom:
                this.y=464;
        }
        this.dialogue = dialogue;
        this.narrator = narrator;
        box = new FlxSprite(0,0);//loadGraphic(Paths.image('dialogue/dialoguebox2', 'preload'));
        box.frames = Paths.getSparrowAtlas('dialogue/dialogueBoxlol', 'preload');
        box.animation.addByPrefix('appears', 'Box appears', 24, false);
        box.animation.addByPrefix('disappears', 'Box disappears', 24, false);
        box.animation.addByPrefix('idle', 'Box idle', 24, false);

        add(box);

        dialogueIndicator = new FlxSprite(610,251).loadGraphic(Paths.image('dialogue/indicator', 'preload'), true, 8, 5);
        dialogueIndicator.scale.set(3,3);
        dialogueIndicator.alpha = 0;
        add(dialogueIndicator);
        dialogueIndicator.animation.add('idle', [0,0,0,1,1,1], 5,true);
        dialogueIndicator.animation.play('idle');
        //var obj = new ObjectController(dialogueIndicator,1);
        //add(obj);

        box.animation.play('appears');
        box.animation.finishCallback = function(_){
            
            //box.animation.pause();
            trace('finished appear');
           

            offTextt = new FlxTypeText(451, 27, 570, '', 25);
      
            offTextt.font = 'assets/fonts/Minecraftia-Regular.ttf';
            offTextt.antialiasing = false;
            add(offTextt);
    
           
            createdia(dialogue);
            
        }

       

    }
    var line:String = '';
    var scaler:Float = 1;
    var shit:Bool = false;
    var size:Int = 10;
    var daWidth:Int = 400;
    private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
    override function destroy(){
		
       
		super.destroy();
	}
    var listenInput:Bool = false;
    override function update(elapsed:Float){
       
        super.update(elapsed);
        FlxG.watch.addQuick('curChar',curCharacter);
        FlxG.watch.addQuick('curline',curCharacter);

        if(listenInput){
            #if debug
            //scaleObject(dialogueIndicator);
            //scaleObject(portrait);
            #end
            if(controls.ACCEPT){
                if (curLine + 1 < dialogue.length)
                    {
                        listenInput=false;
                        dialogueIndicator.alpha = 0;
    
                        curLine++;
                        if(!narrator && curCharacter!='narrator'){
                        portrait.destroy();

                        }
                        createdia(dialogue);

                    }
                    else
                    {
                       trace('finished dia');
                       //box.animation.play('disappears');
                       if(!narrator && curCharacter!='narrator')
                       remove(portrait);
                       remove(offTextt);
                      
                    
                          
                   
                        finishThing();

                
                       destroy();
                   
    
                    }
            }
           
        }
     
    }
    var lastCharacter:String;
    var hasCharacterTalked:Bool =false;
    function userStuff(){
        if (line.indexOf("userName") != -1) {
            if(NameSelectionState.completeName!='')
            line = line.split("userName").join(NameSelectionState.completeName);
            else
                line = line.split("userName").join('Yesnt');

        }
        if (line.indexOf("posesivePronoum") != -1) {
            switch(IntroState.playerSex){
                case 'Male':
                    line = line.split("posesivePronoum").join('His'); 
                case 'Female': 
                    line = line.split("posesivePronoum").join('Her'); 

            }
        }
        if (line.indexOf("playerPronoum") != -1) {
            switch(IntroState.playerSex){
                case 'Male':
                    line = line.split("playerPronoum").join('he'); 
                case 'Female': 
                    line = line.split("playerPronoum").join('she'); 

            }
        }
    }
    function createdia(dia:Array<String>)
        {
            line = dia[curLine];
            trace(line);
            if(line == '-narrator-You have been assigned to a being called "The Batter".'){
                appearBatter();
                trace('appeared batter lol');
            }
            var stateStart = line.indexOf("-");
            var stateEnd = line.lastIndexOf("-");
            if (stateStart != -1 && stateEnd != -1)
            {
                curCharacter = line.substring(stateStart + 1, stateEnd);
                line = line.substring(stateEnd + 1);
    
            } 
            userStuff();

            if(!narrator && curCharacter!='narrator'){
                
               
                var    clone = new FlxSprite(228,50);
                clone.frames = Paths.getSparrowAtlas('rpgshit/BatterRPG', 'preload');
                clone.animation.addByPrefix('idle', 'BatterRPG portrait', 24, false);
                clone.animation.play('idle');
                clone.scale.set(3.9,3.9);
                clone.alpha = .70;
                //add(clone);

                switch(curCharacter){
                    case 'batter':
                        portrait = new FlxSprite(228,50);
                        portrait.frames = Paths.getSparrowAtlas('rpgshit/BatterRPG', 'preload');
                        portrait.animation.addByPrefix('idle', 'BatterRPG portrait', 24, false);
                        portrait.animation.play('idle');
                        portrait.scale.set(3.9,3.9);
                        add(portrait);
                    case 'judge':
                        portrait = new FlxSprite(268,55);
                        portrait.frames = Paths.getSparrowAtlas('rpgshit/JudgeRPG', 'preload');
                        portrait.animation.addByPrefix('idle', 'JudgeRPG portrair', 24, false);
                        portrait.animation.play('idle');
                        portrait.scale.set(3.9,3.9);
                        add(portrait);
                    case 'dedan':
                        portrait = new FlxSprite(250,84);
                        portrait.frames = Paths.getSparrowAtlas('rpgshit/DedanRPG', 'preload');
                        portrait.animation.addByPrefix('idle', 'DedanRPG portrait', 24, false);
                        portrait.animation.play('idle');
                        portrait.scale.set(3.9,3.9);
                        add(portrait);
                    case 'hugo': 
                        portrait = new FlxSprite(250,108);
                        portrait.frames = Paths.getSparrowAtlas('rpgshit/HugoRPG', 'preload');
                        portrait.animation.addByPrefix('idle', 'HugoRPG portrait', 24, false);
                        portrait.animation.play('idle');
                        portrait.scale.set(3.9,3.9);
                        add(portrait);
                    case 'enoch': 
                    portrait = new FlxSprite(355,-14);
                    portrait.frames = Paths.getSparrowAtlas('rpgshit/EnochRPG', 'preload');
                    portrait.animation.addByPrefix('idle', 'EnochRPG portrait', 24, false);
                    portrait.animation.play('idle');
                    portrait.scale.set(3.9,3.9);
                    add(portrait);

                    case 'japhet':
                        portrait = new FlxSprite(261,61);
                        portrait.frames = Paths.getSparrowAtlas('rpgshit/JaphetRPG', 'preload');
                        portrait.animation.addByPrefix('idle', 'JaphetRPG portrait', 24, false);
                        portrait.animation.play('idle');
                        portrait.scale.set(3.9,3.9);
                        add(portrait);
                    case 'queen':
                        portrait = new FlxSprite(230,67);
                        portrait.frames = Paths.getSparrowAtlas('rpgshit/QueenRPG', 'preload');
                        portrait.animation.addByPrefix('idle', 'QueenRPG portrait', 24, false);
                        portrait.animation.play('idle');
                        portrait.scale.set(3.9,3.9);
                        add(portrait);
                    case 'zacharieAfter':
                        portrait = new FlxSprite(69,243);
                        portrait.frames = Paths.getSparrowAtlas('rpgshit/ZacharieRPG', 'preload');
                        portrait.animation.addByPrefix('idle', 'ZacharieRPG afterPortrait', 24, false);
                        portrait.animation.play('idle');
                        portrait.scale.set(3.9,3.9);
                        add(portrait);
                    case 'elsen':
                        portrait = new FlxSprite(258,72);
                        portrait.frames = Paths.getSparrowAtlas('rpgshit/elsen', 'preload');
                        portrait.animation.addByPrefix('idle', 'elsen portrait', 24, false);
                        portrait.animation.play('idle');
                        portrait.scale.set(3.9,3.9);
                        add(portrait);
                    case 'elsenMiner':
                        portrait = new FlxSprite(258,72);
                        portrait.frames = Paths.getSparrowAtlas('rpgshit/elsenMiner', 'preload');
                        portrait.animation.addByPrefix('idle', 'elsenMiner portrait', 24, false);
                        portrait.animation.play('idle');
                        portrait.scale.set(3.9,3.9);
                        add(portrait);
                    case 'zacharie':
                        portrait = new FlxSprite(269,251);
                        portrait.frames = Paths.getSparrowAtlas('rpgshit/ZacharieRPG', 'preload');
                        portrait.animation.addByPrefix('idle', 'ZacharieRPG portrait', 24, false);
                        portrait.animation.play('idle');
                        portrait.scale.set(3.9,3.9);
                        add(portrait);
                    case 'pancat':

                        portrait = new FlxSprite(280,112);
                        portrait.loadGraphic(Paths.image('rpgshit/pancatPortrait', 'preload'));
                        portrait.scale.set(3.9,3.9);
                        add(portrait);
                        
                       
                }

              
                if ((curCharacter != lastCharacter || lastCharacter == null)&& curCharacter!='batter' && curCharacter!='narrator') {
                    FlxG.sound.play(Paths.sound('${curCharacter}Talks', 'preload'));
                }
        
                // Actualiza el personaje actual
                lastCharacter = curCharacter;
                       
            }
           
            if(curCharacter == 'narrator'||narrator){
                offTextt.x = 182;
                offTextt.fieldWidth = 900;
            }
            else{
                offTextt.x = 451;
                offTextt.fieldWidth = 570;
            }
            offTextt.skipKeys = [Z];
            offTextt.resetText(line);
            offTextt.start(0.05, true);
         
            offTextt.completeCallback = function()
            {
                dialogueIndicator.alpha = 1;
               
               listenInput = true;
               
                   
            }
          
        }

        function textWandSize(){
            FlxG.watch.addQuick('size', size);
    
            FlxG.watch.addQuick('width', daWidth);
            if(FlxG.keys.pressed.F){
                shit = !shit;
            }
            if(shit){
                if(FlxG.keys.pressed.E){
                    size += 1;
                }
                if(FlxG.keys.pressed.Q){
                    size  -= 1;
        
                }
            }
            else{
                if(FlxG.keys.pressed.E){
                    daWidth += 1;
                }
                if(FlxG.keys.pressed.Q){
                    daWidth  -= 1;
        
                }
            }
            offTextt.size = size;
            offTextt.fieldWidth = daWidth;
        }
        function scaleObject(object:FlxSprite){
            FlxG.watch.addQuick('scaler', scaler);
            
    
            if(FlxG.keys.pressed.E){
                scaler += 0.1;
            }
            if(FlxG.keys.pressed.Q){
                scaler  -= 0.1;
    
            }
            object.setGraphicSize(Std.int(object.frameWidth*scaler));
        }

}