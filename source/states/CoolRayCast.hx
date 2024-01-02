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
import flixel.group.FlxSpriteGroup;

import OffSaveGame;

class CoolRayCast extends FlxSpriteGroup{

    public static function castRay(sprA:FlxSprite, direction:String, sprB:FlxSprite):Bool {
        
        var ray = new FlxObject(sprA.x, sprA.y, 16, 16);
   
        add(ray);
      
         switch(direction){
            case 'right':
                ray.x = sprA.x + 16; 
            case 'left': 
                ray.x = sprA.x - 16; 
            case 'up': 
                ray.y = sprA.y - 16;
            case 'down':
                ray.y = sprA.y + 16;

         }
         if(ray.overlaps(sprB)){
            return true;
         }
        
        return false;

        ray.destroy();
    }
}