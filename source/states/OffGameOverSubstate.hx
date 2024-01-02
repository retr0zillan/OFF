package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ui.*;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class OffGameOverSubstate extends MusicBeatSubstate
{
	var black:FlxSprite;

    var type:String;
    var canEnter:Bool = false;
    var omgCamera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
	public function new(what:String =  'battletime')
	{
		
	this.type = what;

		

		super();

        black = new FlxSprite().loadGraphic(Paths.image('gameOver/GameOver', 'preload'));
        black.alpha = 0;
        add(black);
        omgCamera.fade(FlxColor.BLACK, 1, false, function(){
            black.alpha = 1;

        });

        switch(MapTestState.instance.curMap){
            case 'level5enochchase':
                MapTestState.fattyDeaths++;
                FlxG.sound.play(Paths.sound('fattyCrush', 'preload'));

            default:
                FlxG.sound.play(Paths.sound('fattyCrush', 'preload'));

        }
        new FlxTimer().start(2, function(_){

            omgCamera.fade(FlxColor.BLACK, 1, true, function(){

                FlxG.sound.playMusic(Paths.music('StayInYourComa', 'preload'));
                canEnter = true;
            });
        });


	
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];


	}

	override function update(elapsed:Float)
	{
        switch(type){
            case 'overworld':
            if(canEnter && controls.ACCEPT){
                omgCamera.fade(FlxColor.BLACK, 1, false, function(){
                    FlxG.switchState(new MapTestState());
        
                });
    
            }
            case 'battletime':
                if(canEnter){
                    if(controls.ACCEPT){
                        omgCamera.fade(FlxColor.BLACK, 1, false, function(){
                            MapTestState.curHealth =PlayState.daIns.healthTracker;
                            LoadingState.loadAndSwitchState(new PlayState());
                
                        });
                    }
                    else if(controls.BACK){
                        omgCamera.fade(FlxColor.BLACK, 1, false, function(){
                            MapTestState.wentoPs=false;
                            FlxG.switchState(new OffMenuState());
                
                        });
                    }
                   
        
                }
        }
        
		super.update(elapsed);

        
	
	
	}

	override function beatHit()
	{
		super.beatHit();

	}


	
}
