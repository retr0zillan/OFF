package;

import flixel.math.FlxPoint;
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
import flixel.group.FlxGroup.FlxTypedGroup;
enum CoolPos{
    Upper;
    Bottom;
}
class CoolDecision extends FlxSpriteGroup
{
    public var box:FlxSprite;
    public var forcedOption:Bool = false;
	var curCharacter:String = 'batter';
	var offTextt:FlxTypeText;
	var curLine:Int = 0;
	public var finishThing:Void->Void;

    var opts:Array<String>=[];
    var portrait:FlxSprite;
    var optText:FlxText;
    var canDecide:Bool = false;
   public var options:Array<FlxText> = [];
    public var bannedOption:Int = 99999999;
    var decideBar:FlxSprite;
    public static var Deciding:Bool = false;
    private var controls(get, never):Controls;
	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
    public function new(opts:Array<String>, ?position:CoolPos = Upper, ?text:String=''){
        super();
        this.opts = opts;

        switch(position){
            case Upper:
                this.y = 0;
            case Bottom:
                this.y=464;
        }
        box = new FlxSprite(0,0);//loadGraphic(Paths.image('dialogue/dialoguebox2', 'preload'));
        box.frames = Paths.getSparrowAtlas('dialogue/dialogueBoxlol', 'preload');
        box.animation.addByPrefix('appears', 'Box appears', 24, false);
        box.animation.addByPrefix('disappears', 'Box disappears', 24, false);
        box.animation.addByPrefix('idle', 'Box idle', 24, false);

        add(box);
        box.animation.play('idle');

        
            offTextt = new FlxTypeText(182, 27, 0, text, 25);
            offTextt.font = 'assets/fonts/Minecraftia-Regular.ttf';
            offTextt.antialiasing = false;
            add(offTextt);
    
            
            portrait = new FlxSprite(228,50);
            portrait.frames = Paths.getSparrowAtlas('rpgshit/BatterRPG', 'preload');
            portrait.animation.addByPrefix('idle', 'BatterRPG portrait', 24, false);
            portrait.animation.play('idle');
            portrait.scale.set(3.9,3.9);
            //add(portrait);
    
          
            decideBar = new FlxSprite(0, 0).loadGraphic(Paths.image('dialogue/selectBarPix', 'preload'));
            decideBar.alpha = 0;
            add(decideBar);
            for(i in 0...opts.length){
                if(text!='')
                optText = new FlxText(200, 81 +(i*50),0, opts[i],25);
                else
                    optText = new FlxText(200, 30 +(i*50),0, opts[i],25);

                optText.font = 'assets/fonts/Minecraftia-Regular.ttf';
                optText.ID = i;
                optText.alpha = 0;
                optText.antialiasing = false;
                add(optText);
                options.push(optText);


            }
            if(text!=''){
                offTextt.resetText(text);
                offTextt.start(0.05, true);
                offTextt.completeCallback = function(){
                    decideBar.alpha = 0.7;
        
                    new FlxTimer().start(0.1, function(_){
                        canDecide = true;
    
                    });
                    changeSel(0);
                }
            }
            else{
                decideBar.alpha = 0.7;
        
                new FlxTimer().start(0.1, function(_){
                    canDecide = true;

                });
                changeSel(0);

            }
           
        

    }
    public static var noquis:Int = 9999;
   function changeSel(shit:Int=0){

    FlxG.sound.play(Paths.sound('opchange', 'preload'));
    curSel += shit;

    if(curSel>opts.length-1)
        curSel = 0;
    if(curSel<0)
        curSel = opts.length-1;

    decideBar.setPosition(options[curSel].x -11, options[curSel].y- 2);

  
    for(o in options){
       
        o.alpha = 1;
        if(o.ID == noquis){
            o.alpha = 0.5;
        }
    }

    
   }
   public var curSel:Int = 0;
   var num:FlxPoint = new FlxPoint();
   function selectHelper(){
    #if debug
    FlxG.watch.addQuick('num', '${num.x}x ${num.y}y');
    decideBar.setPosition(options[curSel].x - num.x, options[curSel].y- num.y);
    if(FlxG.keys.pressed.LEFT){
        num.x -=1;
    }
    if(FlxG.keys.pressed.RIGHT){
        num.x +=1;

    }
    if(FlxG.keys.pressed.UP){
        num.y -=1;

    }
    if(FlxG.keys.pressed.DOWN){
        num.y +=1;

    }
    //scalePortrait();
    #end
   }
    override function update(elapsed:Float){
        super.update(elapsed);

    
        if(!forcedOption)
            {
                if(controls.ACCEPT && canDecide && options[curSel].alpha ==1){
                    FlxG.sound.play(Paths.sound('Chariot1', 'preload'));
        
        
                    finishThing();
                    this.destroy();
                }
            }
            else{
                if(controls.ACCEPT && canDecide && curSel == 0 && options[curSel].alpha ==1){
                    FlxG.sound.play(Paths.sound('Chariot1', 'preload'));
        
        
                    finishThing();
                    this.destroy();
                }
            }
       
        //selectHelper();

        
        if(controls.UP_P  && canDecide){
            changeSel(-1);
        }
        if(controls.DOWN_P  && canDecide){
            changeSel(1);

        }
      
       
    }
   
            

}