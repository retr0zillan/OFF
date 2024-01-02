package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ui.*;
import states.*;
using StringTools;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;

class QuitLayer extends FlxSpriteGroup
{
    public var text:FlxText;
    public var holder:FlxSprite;
    public var bars:FlxSprite;
    public var selector:FlxSprite;
    private var controls(get, never):Controls;
    public var finishThing:Void->Void;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
    var texts:Array<String> = [
        'Quit?',
        'Yes',
        'No'
    ];
    public var container:Array<FlxText>=[];
    public function new()
        {
            super();
                holder = new FlxSprite(0,0);
                holder.loadGraphic(Paths.image('quitMenu/quit', 'preload'));
                holder.antialiasing = false;
                add(holder);

                selector = new FlxSprite(583,427);
                selector.loadGraphic(Paths.image('quitMenu/selector', 'preload'));
                selector.antialiasing = false;
                add(selector);

                for(i in 0...texts.length)
                    {
                        text = new FlxText(601, 370 + i * 66, 0, texts[i], 30);
    
                        text.font = 'assets/fonts/Minecraftia-Regular.ttf';
                
                        add(text);

                        if(i == 0){
                            text.setPosition(593,241);
                            text.size = 35;
                        }
                        if(i>0){
                            container.push(text);

                        }
                    }

                
              
              
                    changeItem(0);

                    bars = new FlxSprite(0,0).loadGraphic(Paths.image('BlackBars1280', 'preload'));
                    bars.scrollFactor.set();
                    add(bars);
        }
        var Deciding:Bool= false;

        var curSelection:Int = 0;
        var num:FlxPoint = new FlxPoint();

        function selectHelper(){
         #if debug
         FlxG.watch.addQuick('num', '${num.x}x ${num.y}y');
         selector.setPosition(container[curSelection].x - num.x, container[curSelection].y - num.y);
         if (FlxG.keys.pressed.LEFT) {
             num.x -= 1;
         }
         if (FlxG.keys.pressed.RIGHT) {
             num.x += 1;
         }
         if (FlxG.keys.pressed.UP) {
             num.y -= 1;
         }
         if (FlxG.keys.pressed.DOWN) {
             num.y += 1;
         }
         //scalePortrait();
         #end
     }
        function changeItem(owo:Int=0){
                curSelection+=owo;
                if (curSelection < 0) {
                    curSelection = container.length - 1;
                }
                if (curSelection >= container.length) {
                    curSelection = 0;
                }
               
                selector.setPosition(container[curSelection].x - 16, container[curSelection].y - 8);

            }
        override function update(elapsed:Float)
            {
                super.update(elapsed);
                #if debug
                //selectHelper();
                #end
                if(controls.ACCEPT && !Deciding){
                    switch(curSelection){
                        case 0:
                            MapTestState.wentoPs=false;
                            FlxG.switchState(new OffMenuState());
                        case 1:
                            trace('shjht');
                            this.destroy();
                            new FlxTimer().start(0.1, function(_){
                                OffPauseSubState.inss.curPage = 10;

                            });

                    }
                }
                if (controls.UP_P && !Deciding) {
                   changeItem(-1);
                }
                if (controls.DOWN_P && !Deciding) {
                   changeItem(1);
                }


            }
}