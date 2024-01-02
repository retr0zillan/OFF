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

class CredisLol extends FlxSpriteGroup{
    var bg:FlxSprite;
    public function new(x:Float, y:Float)
        {
            super(x,y);
            var daCam = MapTestState.instance.overlayCamera;
            this.cameras = [daCam];

            bg = new FlxSprite(0,0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
            daCam.fade(FlxColor.BLACK, 1, false, function(){
                add(bg);

                daCam.fade(FlxColor.BLACK, 1, true, function(){

                startBullshit();
                });
    

            });


        }
        function startBullshit(){
            
        }
        override function update(elapsed:Float){
            super.update(elapsed);
        }
}