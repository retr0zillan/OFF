package states;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import haxe.Exception;
using StringTools;
import flixel.util.FlxTimer;
import Options;
import flixel.input.mouse.FlxMouseEventManager;
import ui.*;
import flixel.math.FlxPoint;
import flixel.util.FlxSave;
import Options;

class OffMenuState extends MusicBeatState{

    var bars:FlxSprite;
    var actualBg:FlxSprite;
    var graySqr:FlxSprite;
    var optsNames:Array<String> = ['New  game', 'Continue', 'Options','Quit'];
    var options:FlxTypedGroup<FlxSprite>;
    var selectSpr:FlxSprite;

    var elSave = OffSaveGame.loadData();
    public static var currentYear:Int;
    override function create() {
        super.create();
        FlxG.mouse.visible = false;
        DiscordClient.changePresence("Main Menu", null, null, true);

        persistentUpdate = true;
		persistentDraw = true;
        

        var currentDate:Date = Date.now();
        currentYear = currentDate.getFullYear();
        
        trace("Ano actual: " + currentYear);
        if(currentYear == 2008){
            trace("Oh yeah");

        }

        FlxG.sound.playMusic(Paths.music('FourteenResidents','preload'));

    

        actualBg = new FlxSprite(0,0).loadGraphic(Paths.image('offMainMenu/MainMenuBG1280', 'preload'));
        add(actualBg);

        graySqr = new FlxSprite(537,491).loadGraphic(Paths.image('offMainMenu/newSqr', 'preload'));

        add(graySqr);

        selectSpr = new FlxSprite(546,491).loadGraphic(Paths.image('offMainMenu/selectSpr', 'preload'));

        add(selectSpr);

        options = new FlxTypedGroup<FlxSprite>();
        add(options);
        for(i in 0...optsNames.length){
            //50 px
            var opt = new FlxText(557, 505+(i*50), 0, optsNames[i], 27);
            opt.font = 'assets/fonts/Minecraftia-Regular.ttf';
            opt.antialiasing = false;
            options.add(opt);
            if(i == 1 && elSave==null){
                opt.alpha=0.4;
            }
            if(i == 0 && currentYear == 2008){
                opt.alpha=0.4;

            }
        
        }
      

        bars = new FlxSprite(0,0).loadGraphic(Paths.image('BlackBars1280', 'preload'));
        add(bars);
        changeSel();
        
        //var obj = new ObjectController(opt, 1);
        //add(obj);
        
    }
    var numba:Int = 0;
    var superNumba:FlxPoint = new FlxPoint();
    var curSelected:Int = 0;
    //5.1 , 10.3
    function changeSel(some:Int=0){
        FlxG.sound.play(Paths.sound('opchange', 'preload'));

        curSelected+=some;
        if(curSelected>optsNames.length-1){
            curSelected = 0;
        }
        if(curSelected<0){
            curSelected = optsNames.length-1;

        }
        selectSpr.y = options.members[curSelected].y - 3;
    }
    function selectDebugShit(){
        var traker = 'numbaX ${superNumba.x} || numbaY ${superNumba.y}';
        FlxG.watch.addQuick('traker', traker);

        selectSpr.x = options.members[0].x - superNumba.x;
        selectSpr.y = options.members[0].y - superNumba.y;

        if(FlxG.keys.pressed.W){
            superNumba.y -= 0.1;
        }
        if(FlxG.keys.pressed.S){
            superNumba.y += 0.1;

        }
        if(FlxG.keys.pressed.A){
            superNumba.x -= 0.1;

        }
        if(FlxG.keys.pressed.D){
            superNumba.x += 0.1;

        }
    }
    function optsdebugShit(){
        FlxG.watch.addQuick('numba', numba);

        if(FlxG.keys.pressed.Q){
            numba -= 1;
            }
        if(FlxG.keys.pressed.E){
            numba += 1;
        }
        for(i in 0...optsNames.length){
            var opt = options.members[i];
            opt.setPosition(561, 513+(i*numba));
           
        }
    }
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        //selectDebugShit();
        #if debug
        if(FlxG.keys.justPressed.EIGHT){
			FlxG.switchState(new MapTestState());
		}
        if(FlxG.keys.justPressed.NINE){
			FlxG.switchState(new StoryMenuState());
            
		}

        if(FlxG.keys.justPressed.ESCAPE){
            FlxG.switchState(new SoundOffsetState());
        }
        #end

        if (FlxG.keys.justPressed.F)
            {
                FlxG.fullscreen = !FlxG.fullscreen;
            }
        if(controls.ACCEPT){
            FlxG.sound.play(Paths.sound('Chariot1', 'preload'));

            switch(curSelected){
                case 0:
                    if(currentYear!=2008)
                    FlxG.switchState(new NameSelectionState());
                case 1:
                    if(elSave!=null){
                        FlxG.switchState(new MapTestState());

                    }
                case 2:
                    FlxG.switchState(new OptionsState());
                case 3:
                    Sys.exit(0);
            }
        }
        if(controls.UP_P){
            changeSel(-1);
        }
        if(controls.DOWN_P){
            changeSel(1);

        }
       
        
    }



















    
}