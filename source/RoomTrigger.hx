package;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.math.FlxPoint;

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
import flixel.tile.FlxTilemap;
import haxe.io.Path;
import flixel.FlxState;
import Options;
import flixel.input.mouse.FlxMouseEventManager;
import ui.*;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledImageTile;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledTilePropertySet;
import openfl.Assets;
import flixel.group.*;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.tile.FlxTileSpecial;
import flixel.addons.editors.tiled.*;
import haxe.io.Path;

class RoomTrigger extends FlxObject{
    public var warpsTo:String;
    public var nextSpawn:Int = 1;
    public function new(x:Float, y:Float, width:Float, height:Float, warpsTo:String){
        super(x,y,width,height);
        this.warpsTo = warpsTo;

    }
    override function update(elapsed:Float){
        super.update(elapsed);
    }
}