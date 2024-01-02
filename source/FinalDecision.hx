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
class FinalDecision extends FlxSpriteGroup{
    var des:FlxSprite;
    public var finishThing:Void->Void;
    var canDecide:Bool = false;

    var container:Array<FlxSprite>=[];
    var animations:Array<String>=['batterChoise', 'judgeChoise'];
    public var curSelection:Int = 0;
    private var controls(get, never):Controls;
	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
    public function new(x:Float, y:Float){
        super(x,y);

        for(i in 0...2){
            des = new FlxSprite(387 + (i*350),292);
            des.loadGraphic(Paths.image('choices/${animations[i]}', 'preload'));
            des.antialiasing=false;
            des.scale.set(1.5,1.5);
            des.ID =i;
            add(des);
            container.push(des);

        }
        //var control = new ObjectController(des,1);
        //add(control);
        new FlxTimer().start(0.1, function(_){
            canDecide = true;

        });
        changeShit(0);
    }
    function changeShit(sex:Int = 0){
        FlxG.sound.play(Paths.sound('opchange', 'preload'));

        curSelection+=sex;
        if(curSelection>animations.length-1)
            curSelection = 0;
        if(curSelection<0)
            curSelection=animations.length-1;


        for(d in container){

            d.color = 0xFF000000;
            if(d.ID == curSelection){
                d.color = 0xFFffffff;
            }
        }
    }
    override function update(elapsed:Float){
        super.update(elapsed);
        if(controls.ACCEPT  && canDecide){
            
            finishThing();

                
            destroy();
        }
        if(controls.RIGHT_P  && canDecide){
            changeShit(1);
        }
        if(controls.LEFT_P  && canDecide){
            changeShit(-1);

        }
    }
}