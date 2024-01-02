package states;

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
import flixel.path.FlxPath;

class TiledLevel  extends TiledMap{
    var layer1:FlxTilemap;
    var layer2:FlxTilemap;
	public var backgroundLayer:FlxGroup;
	public var triggerTiles:FlxGroup;

    var layer3:FlxTilemap;
    public var foregroundTiles:FlxGroup;
    public var judge:DaNpc;

    public var imagesLayer:FlxGroup;
	inline static var c_PATH_LEVEL_TILESHEETS = "assets/data/tile/";
	var collidableTileLayers:Array<FlxTilemap>;
	public var objectsLayer:FlxGroup;
    public var interactableObjects:FlxGroup;

    public var aboveLayer:FlxGroup;
    public function reloadObjects(){
        foregroundTiles.destroy();
        backgroundLayer.destroy();
        objectsLayer.destroy();

       

    }
    public function new(tiledLevel:FlxTiledMapAsset, state:MapTestState)
        {
            super(tiledLevel);
            foregroundTiles = new FlxGroup();
            backgroundLayer = new FlxGroup();
            aboveLayer = new FlxGroup();

            objectsLayer = new FlxGroup();
            interactableObjects = new FlxGroup();
            FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);

            loadObjects(state);

            for (layer in layers)
                {
                    
			    if (layer.type != TiledLayerType.TILE)
				    continue;
                    var tileLayer:TiledTileLayer = cast layer;
                    var tileSheetName:String = tileLayer.properties.get("tilesheet");
                    if (tileSheetName == null)
                        throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";                   
                    var tileSet:TiledTileSet = null;
                    for (ts in tilesets)
                        {
                            if (ts.name == tileSheetName)
                            {
                                tileSet = ts;
                                break;
                            }
                        }
                        if (tileSet == null)
                            throw "Tileset '" + tileSheetName + "' not found. Did you misspell the 'tilesheet' property in '" + tileLayer.name + "' layer?";
                        var imagePath = new Path(tileSet.imageSource);
			            var processedPath = c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;
                        var tilemap = new FlxTilemapExt();
			            tilemap.loadMapFromArray(tileLayer.tileArray, width, height, processedPath, tileSet.tileWidth, tileSet.tileHeight, OFF, tileSet.firstGID, 1, 1);

                        if (tileLayer.properties.contains("animated"))
                            {
                                var tileset = tilesets[tileLayer.properties.get("tilesheet")];
                                var specialTiles:Map<Int, TiledTilePropertySet> = new Map();
                                for (tileProp in tileset.tileProps)
                                {
                                    if (tileProp != null && tileProp.animationFrames.length > 0)
                                    {
                                        specialTiles[tileProp.tileID + tileset.firstGID] = tileProp;
                                    }
                                }
                                var tileLayer:TiledTileLayer = cast layer;
                                tilemap.setSpecialTiles([
                                    for (tile in tileLayer.tiles)
                                        if (tile != null && specialTiles.exists(tile.tileID))
                                            getAnimatedTile(specialTiles[tile.tileID], tileset)
                                        else
                                            null
                                ]);
                            }
                
                        if(tileLayer.properties.contains('invisible')){
                            tilemap.visible = false;
                        }
                      
                        
                         if (tileLayer.properties.contains("nocollide"))
                            {
                                if(!tileLayer.properties.contains('abovePlayer'))
                                backgroundLayer.add(tilemap);
                                else
                                    aboveLayer.add(tilemap);


                            }
                           
                            else
                            {
                                //if (collidableTileLayers == null)
                                    //collidableTileLayers = new Array<FlxTilemap>();
                
                                foregroundTiles.add(tilemap);
                                //collidableTileLayers.push(tilemap);
                            }
                }


        }
        function getAnimatedTile(props:TiledTilePropertySet, tileset:TiledTileSet):FlxTileSpecial
            {
                var special = new FlxTileSpecial(1, false, false, 0);
                var n:Int = props.animationFrames.length;
                var offset = Std.random(n);
                special.addAnimation([
                    for (i in 0...n) props.animationFrames[(i + offset) % n].tileID + tileset.firstGID
                ], (1000 / props.animationFrames[0].duration));
                return special;
            }
        function createTrigger(state:MapTestState, o:TiledObject, level:String){
            var trigger = new RoomTrigger(o.x,o.y, o.width, o.height, o.properties.get('warpsTo'));
            trigger.nextSpawn = Std.parseInt(o.properties.get('nextSpawn'));

            if(!state.triggersMap.exists(level))
                state.triggersMap.set(level, [trigger]);
                else
                    state.triggersMap.get(level).push(trigger);
        }
        
       
            var objcounter:Int = 0;
            public function getPathData(Obj:TiledObject):FlxPath{
               
                var name = Obj.name;
              
                for (layer in layers)
                    {
                        if (layer.type != TiledLayerType.OBJECT)
                            continue;
                        var objectLayer:TiledObjectLayer = cast layer;

                        for (o in objectLayer.objects){
                            if (o.objectType == TiledObject.POLYLINE && o.name == name){
                                trace('found polynes for the path');
                              var points = o.points;
                              for (point in points){
                                //Factor in starting position
                                point.x += o.x;
                                point.y += o.y;
                              }
                        
                              return new FlxPath(points);
                            }
                          }
                    }

              
                return null;
              }
              function loadObject(state:MapTestState, o:TiledObject, g:TiledObjectLayer, group:FlxGroup)
                {
                    var x:Int = o.x;
                    var y:Int = o.y;
            
                    // objects in tiled are aligned bottom-left (top-left in flixel)
                    if (o.gid != -1)
                        y -= g.map.getGidOwner(o.gid).tileHeight;
            
                   
                    switch (o.type.toLowerCase())
                    {
                      
                        case 'catspawn':
                            var p:FlxPath = getPathData(o);
                            if (p == null) 
                                throw "No path found for " + o.name;
                          
                           
                             trace(p.nodes);
                             trace('judge added');
                        case 'spwnfromainroomzone2':
                            var position = new FlxPoint(x,y);
                            state.coolSpawn.set(5, position);

                        case 'spwstairszone2':
                            var position = new FlxPoint(x,y);
                            state.coolSpawn.set(4, position);
    
                       
                            case 'upperminesspwn':
                                var position = new FlxPoint(x,y);
                                state.coolSpawn.set(10, position);

                                case 'damienspwnfromuppermines':
                                    var position = new FlxPoint(x,y);
                                    state.coolSpawn.set(11, position);
    

                        case 'spwnuunlocktostairs':
                            var position = new FlxPoint(x,y);
                            state.coolSpawn.set(7, position);

                            case 'spawnerfroomstairsroom':
                                var position = new FlxPoint(x,y);
                                state.coolSpawn.set(3, position);
                            case 'spawnerfrompuzzle':
                                var position = new FlxPoint(x,y);
                                state.coolSpawn.set(2, position);

                            case 'spawnfromteleport':
                                var position = new FlxPoint(x,y);
                                state.coolSpawn.set(8, position);
                                case 'spawnerfromtrain':
                                    var position = new FlxPoint(x,y);
                                    state.coolSpawn.set(9, position);
                                case 'spwnunlockedzone':
                                    var position = new FlxPoint(x,y);
                                    state.coolSpawn.set(6, position);
                      

                            
                        case 'spawner':
                            var position = new FlxPoint(x,y);
                            state.coolSpawn.set(1, position);
                            trace('spawneradded');

                            case 'spwnfrominterior':
                                var position = new FlxPoint(x,y);
                                state.coolSpawn.set(13, position);

                                case 'spwnfrommines':
                                    var position = new FlxPoint(x,y);
                                    state.coolSpawn.set(14, position);

                               
                                    case 'spwnmines':
                                        var position = new FlxPoint(x,y);
                                        state.coolSpawn.set(15, position);

                                    case 'spwnfromoffice':
                                        var position = new FlxPoint(x,y);
                                        state.coolSpawn.set(16, position);

                                        case 'officespwn':
                                            var position = new FlxPoint(x,y);
                                            state.coolSpawn.set(17, position);

                                            case 'roomafterchasespwn':
                                                var position = new FlxPoint(x,y);
                                                state.coolSpawn.set(18, position);
    
                                                case 'spwnfromafterchaseroom':
                                                    var position = new FlxPoint(x,y);
                                                    state.coolSpawn.set(19, position);

                                                case 'spwnfromhallway':
                                                    var position = new FlxPoint(x,y);
                                                    state.coolSpawn.set(22, position);
        
                                                    case 'spwnqueenzone':
                                                        var position = new FlxPoint(x,y);
                                                        state.coolSpawn.set(23, position);

                                                        case 'spwnfromqueenzone':
                                                            var position = new FlxPoint(x,y);
                                                            state.coolSpawn.set(24, position);

                                                            case 'spwnfrompurifiedhallway':
                                                                var position = new FlxPoint(x,y);
                                                                state.coolSpawn.set(25, position);

                                                                case 'spwnfrompurifiedroom':
                                                                var position = new FlxPoint(x,y);
                                                                state.coolSpawn.set(26, position);

                                                             

                                                                   
                            case 'spwninteriorfromupper':
                                var position = new FlxPoint(x,y);
                                state.coolSpawn.set(12, position);

                          



                                case "purifiedroomtohallway":
                                    createTrigger(state, o, 'theroomPurified');

                                case "purifiedhallwaytoroom":
                                    createTrigger(state, o, 'purifiedhallway');

                                case "queenzonetohallway":
                                    createTrigger(state, o, 'level6queenzone');

                                case "hallwaytoqueenzone":
                                    createTrigger(state, o, 'level6hallway');

                                case "hallwaytoprev":
                                    createTrigger(state, o, 'level6hallway');

                                case "chasetoafterchaseroom":
                                    createTrigger(state, o, 'level5enochchase');

                                    case "afterchaseroomtochase":
                                    createTrigger(state, o, 'level5afterchase');


                                case "chasetooffice":
                                    createTrigger(state, o, 'level5enochchase');

                              case "enochofficetochase":
                                    createTrigger(state, o, 'level5enochzone');


                                case "toupperminesfrommines":
                                    createTrigger(state, o, 'level3mines');

                                    case "togroundmines":
                                        createTrigger(state, o, 'level2-uppermines');

                                case "interiortouppermines":
                                    createTrigger(state, o, 'level2-upperminesinterior');
                                    case "upperminestointerior":
                                        createTrigger(state, o, 'level2-uppermines');
                            case "room":
                                createTrigger(state, o, 'level1');

                                case "todamienstation":
                                    createTrigger(state, o, 'level2-uppermines');
                            case "uppermines":
                                createTrigger(state, o, 'level2-traindamien');
                                case 'mainroomzone2tostairs':
                                    createTrigger(state, o, 'level1');
                                case 'stairszonetounlock':
                                    createTrigger(state, o, 'level1-stairszone');

                                    case 'traintoteleport':
                                        createTrigger(state, o, 'level2-trainelsen');

                                        case 'trainpasttoteleport':
                                        createTrigger(state, o, 'level2-pasttrainelsen');

                                    case "teleportzonetotrain":
                                        createTrigger(state, o, 'level2-teleport');
                        case "stairsroom":
                            createTrigger(state, o, 'level1');
    
                            case "unlockedzonetostairs":
                                createTrigger(state, o, 'level1-unlockedzone');

                            case "stairroom-to-mainroomzone2":
                                createTrigger(state, o, 'level1-stairszone');

                            case "stairroom-to-mainroom":
                                createTrigger(state, o, 'level1-stairszone');
    
                              
                            case "puzzleroom-to-mainroom":
                                createTrigger(state, o, 'level1-puzzlesneak');
    
                       
                    }
                }
        public function loadObjects(state:MapTestState)
            {
                for (layer in layers)
                {
                    if (layer.type != TiledLayerType.OBJECT)
                        continue;
                    var objectLayer:TiledObjectLayer = cast layer;
        
        
                    // objects layer
                    if (layer.name == "buttonAction")
                        {
                            for (o in objectLayer.objects)
                            {
                                var x:Int = o.x;
                                var y:Int = o.y;
                        
                                // objects in tiled are aligned bottom-left (top-left in flixel)
                                if (o.gid != -1)
                                    y -= objectLayer.map.getGidOwner(o.gid).tileHeight;

                                objcounter++;
                                trace('theres a button, counting ${objcounter}');
                                var coolButton = new ActionObject(x,y,o.width, o.height);
                                if(o.properties.contains('id'))
                                coolButton.ID = Std.parseInt(o.properties.get('id'));
                                coolButton.name = o.name;


                                
                                //coolButton.immovable = true;
                                //state.actionObjects.add(coolButton);
                            }
                        }
                    if (layer.name == "buttonObjects")
                        {
                            for (o in objectLayer.objects)
                            {
                                var x:Int = o.x;
                                var y:Int = o.y;
                        
                                // objects in tiled are aligned bottom-left (top-left in flixel)
                                if (o.gid != -1)
                                    y -= objectLayer.map.getGidOwner(o.gid).tileHeight;

                                objcounter++;
                                trace('theres a button, counting ${objcounter}');
                                var coolButton = new FlxObject(x,y,o.width, o.height);
                                if(o.properties.contains('id'))
                                coolButton.ID = Std.parseInt(o.properties.get('id'));
                                //coolButton.immovable = true;
                                //state.interactableObjects.add(coolButton);
                            }
                        }
                    if (layer.name == "objects")
                    {
                        for (o in objectLayer.objects)
                        {
                            
                            switch(o.type.toLowerCase()){
                                default:
                                    loadObject(state, o, objectLayer, objectsLayer);

                            }

                           
                        }
                    }
                }
            }
      public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (foregroundTiles == null)
			return false;

		for (map in foregroundTiles)
		{
			// IMPORTANT: Always collide the map with objects, not the other way around.
			//            This prevents odd collision errors (collision separation code off by 1 px).
			if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate))
			{
				return true;
			}
		}
		return false;
	}
            /*
    function createLevel(){
        var mapData1:String = Assets.getText("assets/data/awower_water.csv");
        var mapData2:String = Assets.getText("assets/data/awower_floor.csv");
        var mapData3:String = Assets.getText("assets/data/awower_edif.csv");

        var mapTilePath:String = "assets/images/146131.png";

        layer1 = new FlxTilemap();
        layer1.loadMapFromCSV(mapData1, mapTilePath, 16, 16);
        add(layer1);

        layer2 = new FlxTilemap();
        layer2.loadMapFromCSV(mapData2, mapTilePath, 16, 16);
        add(layer2);

        layer3 = new FlxTilemap();
        layer3.loadMapFromCSV(mapData3, mapTilePath, 16, 16);
        add(layer3);
    
    }
    */
}



