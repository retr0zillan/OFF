package states;
import Options;

#if desktop
import Discord.DiscordClient;
#end
import sys.FileSystem;
import Shaders;
import flixel.util.FlxCollision;
import flixel.system.FlxAssets.FlxShader;
import openfl.filters.ShaderFilter;
import openfl.filters.ColorMatrixFilter;

import openfl.filters.BitmapFilter;
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
import flixel.system.FlxSound;
import flixel.FlxCamera;
import sys.io.*;
import flixel.path.FlxPath;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import haxe.Exception;
using StringTools;
import flixel.util.FlxTimer;
import Options;
import flixel.math.FlxMath;
import flixel.input.mouse.FlxMouseEventManager;
import ui.*;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.group.*;
import flixel.math.FlxVelocity;
import EngineData.WeekData;
import CoolBox.Behaviour;
import flixel.util.FlxSave;
import flixel.addons.display.FlxBackdrop;
import openfl.Lib;

import OffSaveGame;
class WarningState extends MusicBeatState{
    var warning:FlxSprite;
    var curPage:Int = 1;
    override function create(){
        super.create();
        FlxG.save.data.firstTime = true;
        FlxG.save.flush();
        var temporal = new FlxSprite(0,0).makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
        add(temporal);
        warning = new FlxSprite(-519,-265);
        warning.frames = Paths.getSparrowAtlas('WARNINGs', 'preload');
        warning.animation.addByPrefix('page1', 'WARNINGs0000', 24, false);
        warning.animation.addByPrefix('page2', 'WARNINGs0001', 24, false);

        warning.antialiasing = true;
        warning.animation.play('page'+curPage);
        add(warning);
      
    }
   function changePage(huh:Int = 0){
    curPage += huh;
    if(curPage>3){
        curPage=3;
    }
    else if(curPage<1){
        curPage =1;
    }

    if(curPage<3)
        {
            FlxG.camera.fade(FlxColor.BLACK, 1, false, function(){
                warning.animation.play('page'+curPage);
                FlxG.camera.fade(FlxColor.BLACK, 1, true);

            });


        }
    else if(curPage==3)
        FlxG.switchState(new OffMenuState());

   }
    override function update(elapsed:Float){
        if(controls.ACCEPT){
            
            changePage(1);
        }
        else if(controls.BACK){
            changePage(-1);

           

            
        }
        super.update(elapsed);
    }
}