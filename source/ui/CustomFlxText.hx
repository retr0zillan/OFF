package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.text.FlxText;
using StringTools;
class CustomFlxText extends FlxText{
    public var movementType:String = "list";
	public var targetY:Float = 0;
    public var wantedX:Float = 0;
	public var wantedY:Float = 0;
    public var offsetX:Float = 90;

    public function new(x:Float, y:Float, field:Float,text:String = "", size:Int=27){
        super(x,y);
        this.size = size;
        this.bold = true;
        this.fieldWidth = field;
        this.text = text;
        this.font=Paths.font('Minecraftia-Regular.ttf');


    }
    public function calculateWantedXY(){
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
		switch (movementType){
		
			case 'list':
				wantedY =  (scaledY * 120) + (FlxG.height * 0.48);
				wantedX = offsetX;
			default:
				wantedY = (scaledY * 120) + (FlxG.height * 0.48);
				wantedX = offsetX;
		}
	}
    public function gotoTargetPosition(){
		calculateWantedXY();
		x = wantedX;
		y = wantedY;
	}

    override function update(elapsed:Float){
        super.update(elapsed);
        calculateWantedXY();
			x = FlxMath.lerp(x, wantedX, 0.1);
			y = FlxMath.lerp(y, wantedY, 0.1);
        //calculateWantedXY();
			//y = FlxMath.lerp(y, wantedY, Main.adjustFPS(0.16));
    }
}