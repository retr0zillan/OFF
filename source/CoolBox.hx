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
enum Behaviour{
    Static;
    Regular;
    Actionable;
    Chest;
    Arrow;

}
class CoolBox extends FlxSprite{
 
    var timeElapsed:Float = 0;

    var isPressed:Bool = false;
    public var curAnim:String = '';
   public var behaviour:Behaviour = Regular;
   var initialY:Float;
    public function new(x:Float, y:Float, name:String, ?sheet:String='PuzzleStuffRPG', ?behaviour:Behaviour=Regular){
        super(x,y);
        this.initialY = y;
        this.behaviour = behaviour;
        
        frames = Paths.getSparrowAtlas('rpgshit/${sheet}', 'preload');

        switch(behaviour){
            case Regular,Static,Actionable:
                animation.addByPrefix('idle', '${name}', 2, true);
                 animation.play('idle');
                 this.coolRange = 30;

            case Arrow:
                animation.addByPrefix('idle', '${name}', 3, true);
                animation.play('idle');
            case Chest:
                animation.addByPrefix('closed', '${name}closed', 24, false);
                animation.addByPrefix('open', '${name}open', 24, false);

                animation.play('closed');
        }
     
    }
    var cons:Int = 0;
    public var isOpen:Bool = false;
   function open(){
    animation.play('open');
    isOpen=true;
    }
    override function update(elapsed:Float){
        curAnim = this.animation.curAnim.name;
		timeElapsed += elapsed;
        switch(behaviour){
            case Arrow:
            case Chest:
            case Static:
            case Regular:
                
                y = y + 0.03 * Math.cos((timeElapsed + FlxG.random.int(0,3) * 0.02) * Math.PI);

            case Actionable:

            if(isPressed){
                y = y + 0.02 * Math.cos((timeElapsed + FlxG.random.int(0,3) * 0.02) * Math.PI);

                this.alpha = 0.7;
            }
            else{
                this.y = initialY;
                this.alpha = 1;
            }
        }
        super.update(elapsed);
        
    }
}