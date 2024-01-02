package states;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import Options;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import flixel.util.FlxGradient;
import lime.app.Application;
import openfl.Assets;
import flixel.addons.transition.FlxTransitionSprite.TransitionStatus;
import ui.*;
using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{


		// DEBUG BULLSHIT

		super.create();
		FlxG.autoPause=true;
		persistentUpdate = true;

		/*NGio.noLogin(APIStuff.API);

		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS LOL');
		#end*/

	
		//FlxG.switchState(new OffMenuState());
				if(FlxG.save.data.firstTime!=null)
					FlxG.switchState(new OffMenuState());
				else
				FlxG.switchState(new WarningState());

	}



	


	override function update(elapsed:Float)
	{
		
		super.update(elapsed);
	}


	

	override function beatHit()
	{
		super.beatHit();

	
	}
	
}
