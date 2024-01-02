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
import flixel.util.FlxSort;
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
class MapTestState extends MusicBeatState{
    var pancat:DaNpc;
    var camFollow:FlxObject;
    public static var wentoPs:Bool = false;
    public var collidableObjects:FlxTypedGroup<Dynamic>;
    public var triggerObjects:FlxTypedGroup<FlxObject>;

    public var playerSpawnPos:FlxPoint;
    public var spawnfrompuzzle:FlxPoint;

    public var coolSpawn:Map<Int, FlxPoint> = [];
    public var level:TiledLevel;
   public var player:DaPlayer;
    public var roomPuzzle:FlxObject;
    public var mainRoom:FlxObject;
    public var curSpawn:Int = 1;
    public var previousRoom:String = 'none';
    public var curMap:String = 'level1';
    var weekData:Array<WeekData>;
	public static var skin:String = 'BatterRPG';

    public static var instance:MapTestState;
    public static var fattyDeaths:Int = 0;

    public var triggersMap:Map<String, Array<RoomTrigger>>=[];
    var canGo:Bool = false;
    public function new(?map:String = 'level1'){
        super();

        this.curMap = map;
    }
    //player shit
    public static var myInventory:PlayerInventory = new PlayerInventory();
	public static var curHealth:Int = 120;
    public static var maxHealth:Int = 120;
    public  var curJudgeHealth:Int = 70;
    public  var maxJudgeHealth:Int = 70;

    public static var cowPets:Int = 0;
    public static var playerLevel:Int = 1;
	public static var elsenInteractions:Int = 0;
    public static var rival:String = 'Judge';
    public static var zacharieProgress:Int = 0;
    public function reloadPlayer()
        {
      
            level.aboveLayer.destroy();
            collidableObjects.remove(player, true);
            player.destroy();
            player = new DaPlayer(0,0, skin);
            switch(skin){
                case 'BatterRPGbad':
                //player.offset.set(4.6, 10.8);

                default:
                    //player.offset.set(2.6, 10.8);

            }
          
            trace('i wanna get in');
        
         
    
            player.setPosition(lastKnownPos.x,lastKnownPos.y);

            //player.setPosition(coolSpawn.get(curSpawn).x,coolSpawn.get(curSpawn).y);
    
            camFollow.y = player.getGraphicMidpoint().y -20;
      
            camFollow.x = player.getGraphicMidpoint().x;
            ray.setPosition(player.x,player.y);
         
            collidableObjects.add(player);
            add(ray);
            level = new TiledLevel('assets/data/tile/${curMap}.tmx', this);

            add(level.aboveLayer);


        }
    function switchMap(name:String, ?shouldMove:Bool=true){
        if(OffMenuState.currentYear == 2008 && name == 'level2-trainelsen'){
            name = 'level2-pasttrainelsen';
        }

        if(curCode!='')
            curCode='';
       

        if(!justTeleported){
            FlxG.camera.flash(FlxColor.BLACK, 2);
        }
   
        new FlxTimer().start(1, function(_){
            if(shouldMove)
                {
                    player.canMove = true;
                    trace('i can move now');

                }

        });
        previousRoom = curMap;
        curMap = name;

        

       
      
      
         
        level.backgroundLayer.destroy();
        level.foregroundTiles.destroy();
        level.aboveLayer.destroy();

        level.objectsLayer.destroy();
        collidableObjects.destroy();
        triggerObjects.destroy();
        collidableObjects = new FlxTypedGroup<Dynamic>();
        triggerObjects = new FlxTypedGroup<FlxObject>();

        level = new TiledLevel('assets/data/tile/${name}.tmx', this);

        add(level.backgroundLayer);

        add(level.foregroundTiles);

		add(level.objectsLayer);

        add(collidableObjects);
        add(triggerObjects);

        player.setPosition(coolSpawn.get(curSpawn).x,coolSpawn.get(curSpawn).y);

        camFollow.y = player.getGraphicMidpoint().y -20;
  
        camFollow.x = player.getGraphicMidpoint().x;
        if(name=='nothing' && bars.visible){
            bars.visible=false;
        }
        else{
            bars.visible=true;

        }

        loadMapObjects();
        
        FlxG.sound.playMusic(Paths.music(mapSongs.get(curMap),'preload'));
        if((name.startsWith('level2')||name=='level3mines') && currentProgress>=40 && OffMenuState.currentYear!=2008){
            FlxG.sound.playMusic(Paths.music('NotSafe', 'preload'));

        }

      
         
        

  
    }
    public var camShaders=[];
    public var temporal:Bool = false;
    public function removeCamEffect(effect:ShaderEffect, camera:FlxCamera){
        camShaders.remove(effect);
        var newCamEffects:Array<BitmapFilter>=[];
        for(i in camShaders){
          newCamEffects.push(new ShaderFilter(i.shader));
        }
        camera.setFilters(newCamEffects);
      
      }
    public function addCamEffect(effect:ShaderEffect, camera:FlxCamera){
        camShaders.push(effect);
        var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
        for(i in camShaders){
          newCamEffects.push(new ShaderFilter(i.shader));
        }
        camera.setFilters(newCamEffects);
       
    
      }
    public var camGame:FlxCamera;
	public var overlayCamera:FlxCamera;
	public var camHUD:FlxCamera;
    var coolShader:AnotherEffect;
    var elSave:SaveData;
    var ray:FlxObject;
   
 
    var batterInitalPos:FlxPoint = new FlxPoint(0,0);
    var coolBounds:FlxGroup;
    function batterRay(object:FlxSprite):Bool {
       
        if(ray.overlaps(object)){
            return true;
        }
        return false;
    }
    override  function create() {
       
        
        DiscordClient.changePresence("Exploring the overworld", null, null, true);

        camGame = new FlxCamera();

		overlayCamera = new FlxCamera();
		camHUD = new FlxCamera();

        FadeTransitionSubstate.nextCamera = camHUD;
        super.create();
        instance = this;
        elSave = OffSaveGame.loadData();

        //nothingness spawn
        coolSpawn.set(5000, new FlxPoint(1152,592));
        //zone 0 spawn
        coolSpawn.set(6000, new FlxPoint(752,1120));
        //zone 1 spawn
        coolSpawn.set(7000, new FlxPoint(480,112));

        //damien station spawn
        coolSpawn.set(9000, new FlxPoint(624,528));
        //elsen station spawn
        coolSpawn.set(10000, new FlxPoint(640,592));

        //dedanOffice spawn
        coolSpawn.set(11111, new FlxPoint(624,688));
        //japhet zone spawn
        coolSpawn.set(12222, new FlxPoint(592,528));
        //mines spwn
        coolSpawn.set(10111, new FlxPoint(448,675));
        //enochoffice spawn
        coolSpawn.set(13333, new FlxPoint(544,688));
        //queenprev spawn
        coolSpawn.set(14444, new FlxPoint(640,528));

        //queenhallwayspwn
        coolSpawn.set(15555, new FlxPoint(656,688));
        //the room
        coolSpawn.set(16666, new FlxPoint(608,688));










        if(elSave!=null && !wentoPs){
       
            trace('loading data');
            var data = elSave;

            NameSelectionState.completeName = data.batterName;
            currentProgress = data.progress;
            maxHealth = data.maxHealth;
            curHealth = data.curHealth;
            playerLevel = data.playerLevel;
            elsenInteractions = data.elsenInteractions;
            curMap = data.currentMap;
            skin = data.skin;
       
            zacharieProgress = data.zacharieProgress;
            cowPets = data.cowPets;
    
            batterInitalPos.set(data.batterPos.x, data.batterPos.y);
            myInventory = data.myInventory.clone();
            for(i in data.myInventory.items){
            trace('item saved ${i.name} quantity is ${i.quantity}');
            }
            
            if(OffMenuState.currentYear == 2008){
                curMap = 'level1';
                batterInitalPos.set(752, 1120);

            }
           
        }
      
        FlxG.sound.cache(Paths.sound('opchange', 'preload'));
        FlxG.sound.cache(Paths.sound('bump2', 'preload'));
        FlxG.sound.cache(Paths.sound('failure2', 'preload'));
        FlxG.sound.cache(Paths.sound('puzzleunlocks', 'preload'));
        FlxG.sound.cache(Paths.sound('enterbattle', 'preload'));
        FlxG.sound.cache(Paths.sound('Chariot1', 'preload'));

        overlayCamera.bgColor.alpha = 0;
        camHUD.bgColor.alpha = 0;
		weekData = EngineData.weekData;

        FlxG.cameras.reset(camGame);
        FlxG.cameras.add(camHUD);

        FlxG.cameras.add(overlayCamera);
   
		FlxCamera.defaultCameras = [camGame];

 
       FlxG.camera.zoom = 3;



        persistentUpdate = true;
		persistentDraw = true;

        collidableObjects = new FlxTypedGroup<Dynamic>();
        triggerObjects = new FlxTypedGroup<FlxObject>();
        level = new TiledLevel('assets/data/tile/${curMap}.tmx', this);
        add(level.backgroundLayer);
        add(level.foregroundTiles);
		add(level.objectsLayer);
        
         if(elSave==null && !wentoPs){
            batterInitalPos.set(coolSpawn.get(curSpawn).x,coolSpawn.get(curSpawn).y);
        }

        add(collidableObjects);

        add(triggerObjects);

       
            Lib.current.stage.application.window.onDropFile.add(function(path:String){

                if(curMap == 'level6queenprev' && currentProgress ==55){
                    trace('path is ${path}');
                    var fileInfo = FileSystem.stat(path);
                    //var fileSize = fileInfo.size;
                     // Leer el contenido del archivo
                    var fileData = sys.io.File.getBytes(path);
                    
                    // Calcular el hash del contenido del archivo
                    var fileHash = haxe.crypto.Md5.encode(fileData.toString());
                    trace(fileHash);

                    //NFTTTTTTTTTTTTTTTTTTTTTTTTTT
                    if(path.contains('key.png') && fileHash == '2a17a1527908cfbda5855456580f09d1'){
                       trace('we got the right image yess');

                       player.canMove = false;
                       var dialogue = new OffDialogue(["-narrator-You've received The Key"], Upper, true);
                       dialogue.box.alpha = .70;

                       dialogue.cameras = [camHUD];
                       add(dialogue);
                       dialogue.finishThing = function(){
                       myInventory.addItem('The Key', 1, 'Where did you get this from?', false,true);
         
                       currentProgress = 57;


                           player.canMove = true;
                          

                       }
                    }

                }
               
               
            });
       

        mapIsLoaded = true;
        player = new DaPlayer(batterInitalPos.x,batterInitalPos.y, skin);
        player.offset.set(0, 6);
        //player.canMove = false;
        collidableObjects.add(player);
        ray = new FlxObject(player.x, player.y, 16, 16);
   
        add(ray);
        add(level.aboveLayer);
      
        coolBounds = FlxCollision.createCameraWall(overlayCamera,true,16);

       
       
        if(wentoPs){
            player.setPosition(lastKnownPos.x,lastKnownPos.y);
            player.animation.play(lastAnim);
            lastMap = '';
            wentoPs = false;

            switch(curMap){
                case 'purifiedhallway':
                    switch(currentProgress){
                        case 90:
                            player.canMove = false;
                            player.dir = 'up';

                            if(rival=='Batter'){

                                player.visible = false;
                                npc = new DaNpc(640,128, 'Judge');
                                npc.dir = 'down';
                               add(npc);
                               camFocus = 'npc';
                            }
                            new FlxTimer().start(1,function(_){
                                switch(rival){
                                    case 'FinalJudge':


                                        var options = new CoolDecision(['Yes', 'No'], Bottom, 'Flip the switch?');
                            
                                        options.box.alpha = .70;
                                        options.cameras = [camHUD];
                                        options.forcedOption = true;
                                        add(options);

                                        options.finishThing = function(){
                                            switch(options.curSel){
                                                case 0:
                                                    var dialogue = new OffDialogue(['-narrator-The switch is now Off.'], Bottom);
                                                    dialogue.box.alpha = .70;
                                                    dialogue.cameras = [camHUD];
                                                    add(dialogue);
                    
                                                    dialogue.finishThing = function(){
                                                        player.dir = 'down';

                                                        new FlxTimer().start(3.3, function(_){
                                                            var dialogue = new OffDialogue(['-batter-The world is pure now.'], Bottom);
                                                            dialogue.box.alpha = .70;
                                                            dialogue.cameras = [camHUD];
                                                            add(dialogue);
                            
                                                            dialogue.finishThing = function(){
                                                                new FlxTimer().start(2,function(_){
                                                                    wentoPs = true;
                                                                    lastKnownPos.set(player.x, player.y);
                                                                    lastAnim = player.animation.curAnim.name;
                                                                    lastMap = curMap;
                                                                    currentProgress = 100;
                    
                                                                overlayCamera.fade(FlxColor.BLACK, 3, false, function(){
                                                                    FlxG.switchState(new TheCreditsState('Batter ending'));
                                                                   
                    
                                                                  
                                                                 }); 
                                                                });
                                                            }
                                                        });
                                                    }
                                                   
                                                case 1:
                                            }
                                        }
                                       
                                        //var dialogue = new OffDialogue(["-batter-Didn't expect you to betray me like that, userName. But it doesn't matter.", '-batter-The world has been completely purified.'], Bottom);

                                    case 'Batter':
                                       
                                    
                                 
                                    
                                                        
                                                       
                                                        new FlxTimer().start(3.3, function(_){
                                                            var dialogue = new OffDialogue(["-judge-Everything is gone now...", '-judge-But at least he wont be able to destroy anything else...', '-judge-Thanks for the help userName...'], Bottom);                                                    
                                                            dialogue.box.alpha = .70;
                                                            dialogue.cameras = [camHUD];
                                                            add(dialogue);
                            
                                                            dialogue.finishThing = function(){
                                                                new FlxTimer().start(2,function(_){
                                                                    wentoPs = true;
                                                                    lastKnownPos.set(player.x, player.y);
                                                                    lastAnim = player.animation.curAnim.name;
                                                                    lastMap = curMap;
                                                                    currentProgress = 100;
                    
                                                                overlayCamera.fade(FlxColor.BLACK, 3, false, function(){
                                                                    FlxG.switchState(new TheCreditsState('Judge ending'));
                                                                   
                    
                                                                  
                                                                 }); 
                                                                });
                                                            }
                                                        });
                                                    
                                                   
                                            
                                        
                                }
                            
                               
                            });
                    }
                 
                     

                default:
            }
        }
      
        loadMapObjects();
       
        
        camFollow = new FlxObject(player.getGraphicMidpoint().x, player.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

       

         //var obj = new ObjectController(options.options[0],1);
         //add(obj);
        bars = new FlxSprite(0,0).loadGraphic(Paths.image('BlackBars1280', 'preload'));
        bars.scrollFactor.set();
        bars.cameras = [overlayCamera];
        add(bars);


        FlxG.sound.playMusic(Paths.music(mapSongs.get(curMap),'preload'));
        if((curMap.startsWith('level2')||curMap=='level3mines') && currentProgress>=40 && OffMenuState.currentYear!=2008){
            FlxG.sound.playMusic(Paths.music('NotSafe', 'preload'));

        }
    }
    var mapSongs:Map<String, String> =[
        'level1'=> 'EmptyWarehouse(out)',
        'level1-stairszone' => 'EmptyWarehouse(in)',
        'level1-puzzlesneak' => 'EmptyWarehouse(in)',
        'level1-unlockedzone'=> 'EmptyWarehouse(out)',
        'nothing'=> 'Silencio',
        'level2-teleport'=> 'RainyDay(out)',
        'level2-trainelsen'=> 'RainyDay(out)',
        'level2-pasttrainelsen'=> 'RainyDay(out)',
        'level2-traindamien'=> 'RainyDay(out)',
        'level2-uppermines'=> 'RainyDay(out)',
        'level2-upperminesinterior'=> 'RainyDay(in)',
        'level3mines' => 'SoftBreeze',
        'level4japhetzone'=>'The_Walls_Are_Listening_(cliff)',
        'level5enochzone'=>'FrontGate2',
        'level5enochchase'=>'The_Race_of_a_thousand_pounds',
        'level5afterchase'=>'FrontGate2',
        'theroom'=>'The_Race_of_a_Thousand_Ants',
        'theroomPurified'=>'The_Race_of_a_Thousand_Ants_(Safe)',
        'level6queenzone'=>'Woman_of_Your_Dreams',
        'level6queenprev'=>'Brain_Plague_(Slow_Rewind)',

    ];
    var sittingJudge:DaNpc;
    var npc:DaNpc;
    var zoneText:FlxText;
    function trainTransition(destination:String, nextSpawn:Int, direction:String){
        var waitTime:Int = 6;
        #if debug
        waitTime = 2;
        #end
      
   
        
        camGame.fade(FlxColor.BLACK, 1, false, function(){
            FlxG.camera.zoom = 1;

            teleport(destination,nextSpawn);

            FlxG.sound.play(Paths.sound('puzzleunlocks', 'preload'));
            var looperMan = new FlxBackdrop(Paths.image('trainTransition/looperman','preload'), X);
        
            looperMan.setPosition(0,-356);
      

            looperMan.antialiasing = false;
   
            looperMan.cameras = [camGame];
            if(direction=='right')
            looperMan.velocity.set(-400, 0);
            else
                looperMan.velocity.set(400, 0);

            add(looperMan);

            var floor = new FlxBackdrop(Paths.image('trainTransition/floor','preload'), X);
            floor.setPosition(0,547);
            floor.antialiasing = false;
   
            floor.cameras = [camGame];
            if(direction=='right')
            floor.velocity.set(-500, 0);
            else
                floor.velocity.set(500, 0);

            add(floor);
   
        
   
            var train = new FlxSprite(481,462).loadGraphic(Paths.image('trainTransition/train','preload'));
            train.cameras = [camGame];
   
            train.antialiasing = false;
            add(train);


            new FlxTimer().start(1,function(_){
                camGame.fade(FlxColor.BLACK, 1, true);
                trainSound = new FlxSound();
                trainSound = FlxG.sound.load(Paths.sound('Train', 'preload'));
                trainSound.play();
       
                timer = new FlxTimer();
                timer.start(0.7,  onTimer,0);
        
                new FlxTimer().start(waitTime, function(_){

                    camGame.fade(FlxColor.BLACK, 1, false, function(){
                        looperMan.destroy();
                        floor.destroy();
                        train.destroy();
                        timer.cancel();

                        for(s in xd){
                            s.stop();
                        }
                        camGame.fade(FlxColor.BLACK, 1, true);
                        player.canMove = true;
                        FlxG.camera.zoom = 3;


                    });
                 
                });
            });
        });

       
        
       


    }
    var dedan:DaNpc;
    var elsen:DaNpc;

    function startDedanCutscene(){

        var black = new CoolBox(958, 292, 'blackBox', 'blackBox');
        black.width = 10;
        black.height = 11;
        black.alpha = 0;
        black.immovable = true;
        black.behaviour = Regular;
        collidableObjects.add(black);

            dedan = new DaNpc(837,272, 'DedanRPG');
           dedan.dir = 'left';
           dedan.immovable = true;
           collidableObjects.add(dedan);
   
          
           elsen.dir = 'right';
      
   
          

           camFocus = 'elsen';
   
           var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/dedanCutscene')));
            var dialogue = new OffDialogue(dialoguee);
            dialogue.cameras = [camHUD];
            dialogue.box.alpha = .70;
   
            add(dialogue);
            dialogue.finishThing = function(){
               trace('and now dedan leaves lol');
              dedan.path = new FlxPath([new FlxPoint(937,274)]);
              dedan.path.axes = X;
              dedan.path.start(null, 80, FORWARD);
              dedan.path.onComplete=function(_){
               dedan.path.cancel();
               FlxTween.tween(black, {alpha:1}, 0.7);
                new FlxTimer().start(1, function(_){
                    var coolteleport = new FlxSprite(dedan.x-32,dedan.y-100);
                    coolteleport.frames = Paths.getSparrowAtlas('rpgshit/teleport');
                    coolteleport.animation.addByPrefix('teleport', 'teleport teleporting', 24, false);
                    coolteleport.animation.play('teleport');
                    add(coolteleport);
                    collidableObjects.remove(dedan, true);

                    FlxG.sound.play(Paths.sound('night', 'preload'));

                    coolteleport.animation.finishCallback=function(_){
                        FlxTween.tween(black, {alpha:0}, 0.7, {onComplete:function(_){
                            black.destroy();
                            elsen.dir = 'down';
                            currentProgress = 27;
                            var colPos:Array<FlxPoint>=[new FlxPoint(896,289), new FlxPoint(896,305)];

                            for(i in 0...2){
                                var obj = new CoolBox(colPos[i].x, colPos[i].y, 'Lima1');
                                obj.behaviour = Static;
                                obj.immovable = true;

                                obj.ID = 55;
                                collidableObjects.add(obj);
                            }
                            var dialogue = new OffDialogue(['-elsenMiner-What...What should i do?']);
                            dialogue.cameras = [camHUD];
                            dialogue.box.alpha = .70;
                    
                            add(dialogue);
                            dialogue.finishThing = function(){
                                FlxG.camera.flash(FlxColor.BLACK, 2);
                                camFocus = 'player';
                                player.canMove = true;

                            }
                        }});


                        trace('removing dedan');
                        coolteleport.destroy();
        
                    }
                });

              }
   
            }
            new FlxTimer().start(1.1, function(_){
                player.canMove = false;

        });
      
        
    }
    var trainSound:FlxSound;
    var xd:Array<FlxSound>=[];
    private function onTimer(timer:FlxTimer):Void {
        // Reproduce el sonido del tren
        trace('chuchu');
       var anotherOne = new FlxSound();
       anotherOne = FlxG.sound.load(Paths.sound('Train', 'preload'));
       anotherOne.play();
       xd.push(anotherOne);
      }
    var timer:FlxTimer;
      var ghostContainer:Array<DaNpc> = [];
      var zacharie:FlxSprite;
    function startGhostCutscene(){
       

        player.autoPilot = true;
        player.path = new FlxPath([new FlxPoint(816,352)]);
        player.path.autoCenter=false;

    
        player.path.start(null, 100, FORWARD);
        player.path.onComplete=function(_){
            player.path.cancel();
         
            //player.velocity.set(0,0);
          
            player.autoPilot = false;
            player.canMove = false;
            player.dir = 'up';

            var gPositions:Array<FlxPoint> = [

                new FlxPoint(796,318),
                new FlxPoint(796,354),
                new FlxPoint(837,318),
                new FlxPoint(837,354)

            ];
          
                for(i in 0...4){
                    var ghost = new DaNpc(gPositions[i].x,gPositions[i].y, 'GhostRPG', null,true);
                    ghost.alpha = 0;
                    switch(i){
                        case 0,1:
                            ghost.animation.play('right');

                        case 2,3:
                            ghost.animation.play('left');

                    }
                    add(ghost);
                    ghostContainer.push(ghost);
                }
                var currentGhostIndex:Int = 0;

                var timer:FlxTimer = new FlxTimer();

              
                new FlxTimer().start(1, function(_){
                    player.canMove = false;

                    var dialogue = new OffDialogue(['-batter-Show yourselves.'], Bottom);
                    dialogue.box.alpha = .70;
                    dialogue.cameras = [camHUD];
                    add(dialogue);
                    dialogue.finishThing = function(){
                        timer.start(1, function(_) {

                            if (currentGhostIndex < ghostContainer.length) {
                                var ghost:DaNpc = ghostContainer[currentGhostIndex];
                                ghost.alpha = 1;
                                FlxG.sound.play(Paths.sound('aparition', 'preload'));
        
                                // Reproducir el sonido aquí
                                
                                currentGhostIndex++;
                                if(currentGhostIndex == ghostContainer.length){
                                    new FlxTimer().start(1, function(_){
                                        player.dir = 'down';
                                    
                                        var dialogue = new OffDialogue(['-batter-...', '-batter-Prepare yourselves to suffer my judgement.'], Bottom);
                                        dialogue.box.alpha = .70;
                                        dialogue.cameras = [camHUD];
                                        add(dialogue);
                                        dialogue.finishThing = function(){
                                            player.y = 352;
                                            enterBattle(1, 37, 'Ghost');
                                        }
                                         trace('finished shit lol');
                                    });
                                    
                                }
                                timer.reset(0.3); // Reiniciar el temporizador para la próxima aparición
                            }


                        });
                    }
                });
                    
            
            
            //var controller = new ObjectController(ghostContainer[2],1);
            //add(controller);
        }

    }
    function startDedanBatterCutscene(){
        dedan.dir = 'down';
        var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/dedanvsBatter')));
        var dialogue = new OffDialogue(dialoguee);
        dialogue.cameras = [camHUD];
        dialogue.box.alpha = .70;

        add(dialogue);
        dialogue.finishThing = function(){
            enterBattle(2, 40, 'Dedan');
        }
    }
    function startEnochCutscene(){
        player.path = new FlxPath([new FlxPoint(640,688)]);
        player.path.autoCenter=false;

        player.path.start(null, 100, FORWARD);
        player.path.axes = X;
        player.path.onComplete = function(_){
            player.path.cancel();
            player.dir = 'up';
            
            new FlxTimer().start(1.5, function(_){
                
                var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/batterandEnochdialogue')));
              
                var dialogue = new OffDialogue(dialoguee);
                dialogue.cameras = [camHUD];
                dialogue.box.alpha = .70;
    
                add(dialogue);
                dialogue.finishThing = function(){
                    for(c in collidableObjects){
                        if(c.ID == 222){
                            collidableObjects.remove(c, true);
                            break;
                        }
                    }

                    var enochChase = new FlxSprite(593,561);
                    enochChase.frames = Paths.getSparrowAtlas('rpgshit/enochRPGchase','preload');
                    enochChase.animation.addByPrefix('lardass','enochRPGchase walk', 7, true);
                    enochChase.antialiasing = false;
                    enochChase.animation.play('lardass');
                    //enochChase.immovable = true;
                    enochChase.ID = 222;
                    
                    triggerObjects.add(enochChase);

                    new FlxTimer().start(1, function(_){
                        var dialogue = new OffDialogue(['-enoch-You better start running Batter!']);
                        dialogue.cameras = [camHUD];
                        dialogue.box.alpha = .70;
            
                        add(dialogue);
                        dialogue.finishThing = function(){
                            new FlxTimer().start(1, function(_){
                                player.path = new FlxPath([new FlxPoint(640, 704)]);
                                player.path.autoCenter=false;

                                player.path.axes = Y;
                                player.path.start(null,100, FORWARD);
                               
                            });
                        }

                    });
                }
            });
        

        }
    }
    var enochChase:FlxSprite;
    var blackCum:BlackEffect;
    public var grayFilt:ColorMatrixFilter;
    public var grayMatrix:Array<Float> = [
		0.5, 0.5, 0.5, 0, 0,
		0.5, 0.5, 0.5, 0, 0,
		0.5, 0.5, 0.5, 0, 0,
		  0,   0,   0, 1, 0,
	];
    function loadMapObjects(){
       
       
        if(curMap.startsWith('level2')){
        
            if(currentProgress<40||OffMenuState.currentYear==2008)
                {
                    trace('this level doesnt have shaders');
                    camShaders = [];
                    overlayCamera.setFilters([]);
        
                    camGame.setFilters([]);

                    if(camShaders.length<=0 && curMap.indexOf('interior') == -1 ){
                        coolShader = new AnotherEffect();
                        addCamEffect(coolShader,FlxG.camera);
                        trace('adding rain lol');
                    }
                    
                }
            else if(currentProgress>=40){
                if(camShaders.length<=0){
                    /*
                    grayFilt = new ColorMatrixFilter(grayMatrix);
                    camGame.setFilters([grayFilt]);
                    */
                    blackCum = new BlackEffect();
                    addCamEffect(blackCum,FlxG.camera);

                    trace('adding black lol');
                }
            }
          
          
        }
        else if(curMap == 'level3mines'){
            trace('this level doesnt have shaders');
            camShaders = [];
            overlayCamera.setFilters([]);

            camGame.setFilters([]);

            if(currentProgress>=40){
                if(camShaders.length<=0){
                    /*
                    grayFilt = new ColorMatrixFilter(grayMatrix);
                    camGame.setFilters([grayFilt]);
                    */
                    blackCum = new BlackEffect();
                    addCamEffect(blackCum,camGame);

                    trace('adding black lol');
                }
            }
        }
        else{
            trace('this level doesnt have shaders');
            camShaders = [];
            overlayCamera.setFilters([]);

            camGame.setFilters([]);

        }
     


        if(justTeleported){
            trace('mosaiiiiic');
        var effect = new MosaicEffect();
        addCamEffect(effect, camGame);
        var effectTween:FlxTween;
        effectTween = FlxTween.num(MosaicEffect.DEFAULT_STRENGTH, 1, 1.7, {type: ONESHOT, onComplete:function(_){
            trace('we teleport back in');
            var coolteleport = new FlxSprite(player.x-35,player.y-103);
            coolteleport.frames = Paths.getSparrowAtlas('rpgshit/teleport');
            coolteleport.animation.addByPrefix('teleport', 'teleport teleporting', 24, false);
            coolteleport.animation.play('teleport');
            add(coolteleport);
            FlxG.sound.play(Paths.sound('night', 'preload'));

            removeCamEffect(effect, camGame);
            coolteleport.animation.finishCallback=function(_){
                canGo = false;
                justTeleported=false;
                player.visible=true;
                player.canMove = true;
                trace('i can move now');

                
                coolteleport.destroy();
            }
        }}, function(v)
            {
                effect.setStrength(v, v);
                
            });
            
        }
        switch(curMap){

          
            case 'level2-pasttrainelsen':
             if(zacharieProgress == 85){
                if(myInventory.findItemByName("Zacharie's Mask")==null){
                    var mask = new FlxSprite(517,512).loadGraphic(Paths.image('zachStuff/ZacharieMask','preload'));
                    mask.antialiasing = false;
                    mask.immovable = true;
                    mask.ID = 421;
                    collidableObjects.add(mask);
                }
         

             }
             var elsen1 = new DaNpc(737,586 +10,'elsen');
             elsen1.dir = 'down';
             elsen1.ID = 711;
             elsen1.coolRange = 40;
             elsen1.immovable = true;
             collidableObjects.add(elsen1);

             var elsen2 = new DaNpc(689,536,'elsenMiner');
             elsen2.dir = 'up';
             elsen2.ID = 712;
             elsen2.coolRange = 40;

             elsen2.immovable = true;
             collidableObjects.add(elsen2);

             var elsen3 = new DaNpc(544,586 +10,'elsenMiner');
             elsen3.dir = 'up';
             elsen3.ID = 713;
             elsen3.coolRange = 40;

             elsen3.immovable = true;
             collidableObjects.add(elsen3);

            case 'purifiedhallway':
                switch(currentProgress){
                case 100:
                    var judge = new DaNpc(640,128, 'Judge');
                    judge.dir = 'down';
                    judge.alpha = .60;
                    judge.coolRange = 30;
                    judge.ID = 151;
                    judge.immovable = true;

                    collidableObjects.add(judge);

                    var black = new CoolBox(720, 96, 'CoolBoxes black save idle', 'CoolBoxes');
                    black.offset.set(-3,5);

                    black.immovable = true;
                    black.behaviour = Static;
                    collidableObjects.add(black);
                case 90:
                    trace('wait oh yeahh wait a minute mr postman');
                default:
                    var black = new CoolBox(720, 96, 'CoolBoxes black save idle', 'CoolBoxes');
                    black.offset.set(-3,5);

                    black.immovable = true;
                    black.behaviour = Static;
                    collidableObjects.add(black);



                case 75:
                    var autopilot = new FlxObject(640, 240, 16,16);
                    autopilot.ID = 190;
                    triggerObjects.add(autopilot);
                }

                case  'theroomPurified':

                if(currentProgress == 100){
                    var hugo = new FlxSprite(615,626);
                    hugo.frames = Paths.getSparrowAtlas('rpgshit/HugoRPG');
                    hugo.animation.addByPrefix('idle', 'HugoRPG idle', 7, true);
                    hugo.alpha = .60;
                    hugo.ID = 151;
                    hugo.immovable = true;
                    hugo.coolRange = 30;

                    hugo.animation.play('idle');
                    collidableObjects.add(hugo);
                }
            case 'theroom':
                switch(currentProgress){
                    case 60:
                    var hugo = new FlxSprite(615,626);
                    hugo.frames = Paths.getSparrowAtlas('rpgshit/HugoRPG');
                    hugo.animation.addByPrefix('idle', 'HugoRPG idle', 7, true);
                    hugo.animation.play('idle');
                    collidableObjects.add(hugo);

                    player.autoPilot = true;
                    new FlxTimer().start(5, function(_){
                        player.path = new FlxPath([new FlxPoint(player.x, 672)]);
                        player.path.autoCenter=false;

                        player.path.axes = Y;
                        player.path.start(null, 100, FORWARD);
                        player.path.onComplete = function(_){
                            player.path.cancel();
                            new FlxTimer().start(0.7, function(_){
                                var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/batterAndHugo')));
                                        
                                var dialogue = new OffDialogue(dialoguee);
                                dialogue.cameras = [camHUD];
                                dialogue.box.alpha = .70;
                    
                                add(dialogue);
                                dialogue.finishThing = function(){
                                    enterBattle(6, 75, 'Hugo');
                                }
                            });
                        }
                    });

                }
            case 'level6queenzone':
                switch(currentProgress){
                    case 100:
                        var queen = new FlxSprite(650,101);
                        queen.alpha = .60;
                        queen.frames = Paths.getSparrowAtlas('rpgshit/QueenRPG');
                        queen.animation.addByPrefix('idle', 'QueenRPG idle', 24, false);
                        queen.ID = 151;
                        queen.immovable = true;
                        queen.coolRange = 30;

                        queen.animation.play('idle');
                        collidableObjects.add(queen);


                        var black = new CoolBox(656, 32, 'CoolBoxes black save idle', 'CoolBoxes');
                        black.offset.set(-3,5);
                        black.immovable = true;
                        black.behaviour = Static;
                        collidableObjects.add(black);
                    default:
                        var black = new CoolBox(656, 32, 'CoolBoxes black save idle', 'CoolBoxes');
                        black.offset.set(-3,5);
                        black.immovable = true;
                        black.behaviour = Static;
                        collidableObjects.add(black);

                    case 59:
                        var queen = new FlxSprite(650,101);
                        queen.frames = Paths.getSparrowAtlas('rpgshit/QueenRPG');
                        queen.animation.addByPrefix('idle', 'QueenRPG idle', 24, false);
                        queen.animation.play('idle');
                        collidableObjects.add(queen);

                        var pos:Array<FlxPoint>=[
                            new FlxPoint(640,256),
                            new FlxPoint(656,256)
                        ];
                        for(i in 0...2){
                            var autopilot = new FlxObject(pos[i].x, pos[i].y, 16,16);
                            autopilot.ID = 129;
                            triggerObjects.add(autopilot);
                        }
                
                }
            case 'level6hallway':
                switch(currentProgress){
                    case 57:
                        var poopy:Array<FlxPoint>= [
                            new FlxPoint(640,464),
                            new FlxPoint(656,464),
                            new FlxPoint(672,464)
                        ];
                        for(i in 0...3){
                            var ass = new FlxObject(poopy[i].x, poopy[i].y, 16,16);
                            ass.ID = 123;
                            triggerObjects.add(ass);
                        }
                        
                }
            case 'level6queenprev':
                switch(currentProgress){
                    default:
                        var locked=new FlxObject(640,512,16,16);
                        locked.immovable = true;
                        locked.ID = 888;
                        locked.coolRange = 50;
                        collidableObjects.add(locked);
                }
            
            case 'level5afterchase':
                switch(currentProgress){
                    case 45:
                        player.autoPilot = true;
                        player.path = new FlxPath([new FlxPoint(347,631)]);
                        player.path.autoCenter=false;

                        player.path.axes = Y;
        
                        player.path.start(null, 100, FORWARD);
                        player.path.onComplete=function(_){
                            player.path.cancel();
                            player.dir = 'up';
                            new FlxTimer().start(1.5, function(_){
                                enochChase = new FlxSprite(562,402);
                                enochChase.frames = Paths.getSparrowAtlas('rpgshit/enochRPGchase','preload');
                                enochChase.animation.addByPrefix('lardass','enochRPGchase walk', 7, true);
                                enochChase.antialiasing = false;
                                enochChase.animation.play('lardass');
                                //enochChase.immovable = true;
                                enochChase.ID = 222;
                                
                                triggerObjects.add(enochChase);
                                
                                enochChase.path = new FlxPath([new FlxPoint(310, 557)]);
                                enochChase.path.axes = Y;
                                enochChase.path.start(null, 15, FORWARD);
                                enochChase.path.onComplete=function(_){
                                    enochChase.path.cancel();
                                    new FlxTimer().start(2, function(_){
                                        var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/tiredEnochtalksBatter')));
                                        
                                        var dialogue = new OffDialogue(dialoguee);
                                        dialogue.cameras = [camHUD];
                                        dialogue.box.alpha = .70;
                            
                                        add(dialogue);
                                        dialogue.finishThing = function(){
                                            enterBattle(4, 50, 'Enoch');
                                        }
                                    });
        
                                }
        
                            });
                        }
                }
                
            case 'level5enochchase':
                
                if(currentProgress>=50 && zacharieProgress == 70 && myInventory.findItemByName("Zacharie's Book")==null){
                    var book = new FlxSprite(290,612).loadGraphic(Paths.image('zachStuff/zachBook','preload'));
                    book.antialiasing = false;
                    book.immovable = true;
                    book.ID = 421;
                    collidableObjects.add(book);
                }
                switch(currentProgress){
                    case 45:
                        player.path.cancel();
                       player.dir = 'down';
                       player.path = new FlxPath([new FlxPoint(352,304)]);
                       player.path.axes = Y;
                       player.path.autoCenter=false;
                       player.path.start(null, 100, FORWARD,false, true);
                       //296???
                       player.path.onComplete=function(_){
                        player.path.cancel();
                        new FlxTimer().start(1, function(_){
                            var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/batterTalkstoPlayeraboutenoch')));
                           
                            var dialogue = new OffDialogue(dialoguee);
                            dialogue.cameras = [camHUD];
                            dialogue.box.alpha = .70;
                
                            add(dialogue);
                            dialogue.finishThing = function(){
                                new FlxTimer().start(1, function(_){
                                    player.dir = 'up';
                                     enochChase = new FlxSprite(310,24);
                                    enochChase.frames = Paths.getSparrowAtlas('rpgshit/enochRPGchase','preload');
                                    enochChase.animation.addByPrefix('lardass','enochRPGchase walk', 7, true);
                                    enochChase.antialiasing = false;
                                    enochChase.animation.play('lardass');
                                    //enochChase.immovable = true;
                                    enochChase.ID = 222;
                                    
                                    triggerObjects.add(enochChase);

                                    enochChase.path = new FlxPath([new FlxPoint(310, 220)]);
                                    enochChase.path.axes = Y;
                                    enochChase.path.start(null, 30, FORWARD);

                                    enochChase.path.onComplete=function(_){
                                        enochChase.path.cancel();
                                        camGame.shake(0.001, 0.5, null, true, XY);
                                        new FlxTimer().start(1, function(_){
                                            var dialogue = new OffDialogue(['-enoch-I will catch you Batter!']);
                                            dialogue.cameras = [camHUD];
                                            dialogue.box.alpha = .70;
                                
                                            add(dialogue);
                                            dialogue.finishThing = function(){
                                                player.autoPilot = false;
                                                new FlxTimer().start(1.7, function(_){
                                                    enochChase.path = new FlxPath([new FlxPoint(310, 1266)]);
                                                    enochChase.path.axes = Y;
                                                    enochChase.path.start(null, 30, FORWARD);

                                                    new FlxTimer().start(2.5, function(_){
                                                        if(fattyDeaths<3)
                                                        enochChase.path.setProperties(80, FORWARD);
                                                        else
                                                            enochChase.path.setProperties(35, FORWARD);


                                                    });
                                                });
                                             
                                            }

                                        }); 

                                    }

                                });
                            }
                        });
                      
                       }
                }
            case 'level5enochzone':
                switch(currentProgress){
                
                    case 100:
                        var enoch = new FlxSprite(592,528);
                        enoch.frames = Paths.getSparrowAtlas('rpgshit/EnochRPG','preload');
                        enoch.animation.addByPrefix('lardass','EnochRPG idle', 24, false);
                        enoch.antialiasing = false;
                        enoch.alpha = .60;
                        enoch.animation.play('lardass');
                        enoch.immovable = true;
                        enoch.ID = 151;
                        enoch.coolRange = 70;
                        enoch.immovable = true;

                        collidableObjects.add(enoch);


                        

                        var black = new CoolBox(720,688, 'CoolBoxes black save idle', 'CoolBoxes');
                     
                        black.immovable = true;
                        black.offset.set(-3,5);

                        black.behaviour = Static;
                        collidableObjects.add(black);

                    default:
                        var black = new CoolBox(720,688, 'CoolBoxes black save idle', 'CoolBoxes');

                        black.immovable = true;
                        black.offset.set(-3,5);

                        black.behaviour = Static;
                        collidableObjects.add(black);

                    case 45:
                        var enoch = new FlxSprite(592,528);
                        enoch.frames = Paths.getSparrowAtlas('rpgshit/EnochRPG','preload');
                        enoch.animation.addByPrefix('lardass','EnochRPG idle', 24, false);
                        enoch.antialiasing = false;
                        enoch.animation.play('lardass');
                        enoch.immovable = true;
                        enoch.ID = 222;
                        
                        collidableObjects.add(enoch);
                        player.autoPilot = true;

                        new FlxTimer().start(3, function(_){
                            startEnochCutscene();

                        });
                }
              

            case 'level4japhetzone':
                switch(currentProgress){
                
                    case 100:
                        var japhet = new DaNpc(622, 126, 'JaphetRPG', null, true);
                        japhet.alpha = .60;
                        japhet.animation.play('sit');
                        japhet.ID = 151;
                        japhet.coolRange = 30;
                        japhet.immovable = true;
                        collidableObjects.add(japhet);

                        var black = new CoolBox(560, 480, 'CoolBoxes black save idle', 'CoolBoxes');
                        black.offset.set(-3,5);

                        black.immovable = true;
                        black.behaviour = Static;
                        collidableObjects.add(black);
                    case 40:
                        var japhet = new DaNpc(622, 126, 'JaphetRPG', null, true);
                        japhet.animation.play('sit');
                        japhet.immovable = true;
                        collidableObjects.add(japhet);
        
                        var autopilot = new FlxObject(688,176,16,16);
                        autopilot.ID = 777;
                        triggerObjects.add(autopilot);
                     default:
                        var black = new CoolBox(560, 480, 'CoolBoxes black save idle', 'CoolBoxes');
                      
                        black.immovable = true;
                        black.offset.set(-3,5);

                        black.behaviour = Static;
                        collidableObjects.add(black);
                }
                
               
                if(currentProgress<45){
                    zacharie = new FlxSprite(736,480);
                    zacharie.frames = Paths.getSparrowAtlas('rpgshit/ZacharieRPG', 'preload');
                    zacharie.animation.addByPrefix('normal', 'ZacharieRPG idle2_', 24, false);
                    zacharie.animation.play('normal');

                    zacharie.ID = 220;
                    zacharie.coolRange = 40;

                    zacharie.offset.set(33,78);
                    zacharie.immovable = true;

                    collidableObjects.add(zacharie);
                }
                else if(currentProgress==45){
                    zacharie = new FlxSprite(736,480);
                    zacharie.frames = Paths.getSparrowAtlas('rpgshit/ZacharieRPG', 'preload');
                    zacharie.animation.addByPrefix('after', 'ZacharieRPG afterJaphet2_', 24, false);
                    zacharie.animation.play('after');
                    zacharie.offset.set(223,80);


                    zacharie.ID = 220;
                    zacharie.immovable = true;
                    zacharie.coolRange = 40;
                    collidableObjects.add(zacharie);
                 
                    trace('i am after zacharie');
                }
                else{
                    trace('no zacharie');
                }
               


            case 'level3dedanoffice':
                switch(currentProgress){
                    case 100:
                      
                  
                            var finalDedan = new DaNpc(620,612, 'DedanRPG');
                            finalDedan.alpha = .60;
                            finalDedan.dir = 'down';

                            finalDedan.ID = 151;
                          
                            finalDedan.coolRange = 30;
                   
                            finalDedan.immovable = true;
                            collidableObjects.add(finalDedan);
                   
                            var black = new CoolBox(480, 672, 'CoolBoxes black save idle', 'CoolBoxes');
                          
                            black.immovable = true;
                            black.offset.set(-3,5);

                            black.behaviour = Static;
                            collidableObjects.add(black);
                    default:

                 var black = new CoolBox(480, 672, 'CoolBoxes black save idle', 'CoolBoxes');
             
                 black.immovable = true;
                 black.offset.set(-3,5);

                 black.behaviour = Static;
                 collidableObjects.add(black);

                
                 case 37:
                 dedan = new DaNpc(620,612, 'DedanRPG');
                 dedan.dir = 'up';
                 dedan.immovable = true;
                 collidableObjects.add(dedan);


           
                 player.autoPilot = true;
                 player.dir = 'up';
                 new FlxTimer().start(7, function(_){
                    player.autoPilot = false;
                    player.canMove = false;
                    startDedanBatterCutscene();
                 });

                
                }
               

            case 'level3mines':
                var autoPilot = new FlxObject(816,480, 16,16);
                autoPilot.ID = 22;
                triggerObjects.add(autoPilot);

                var black = new CoolBox(720, 352, 'CoolBoxes black save idle', 'CoolBoxes');
                black.offset.set(-3,5);

                black.immovable = true;
                black.behaviour = Static;
                collidableObjects.add(black);

                if(currentProgress==100){
                  
                        var finalGhost = new DaNpc(816,343, 'GhostRPG');
                        finalGhost.alpha = .60;
                        finalGhost.dir='down';
                        finalGhost.ID = 151;
                      
                        finalGhost.coolRange = 30;
               
                        finalGhost.immovable = true;
                        collidableObjects.add(finalGhost);
                }
            case 'nothing':
                var positions:Array<FlxPoint>=[
                    new FlxPoint(1151, 601),
                    new FlxPoint(1143, 654),
                    new FlxPoint(1219, 613),
                    new FlxPoint(1233, 654),
                    new FlxPoint(1259, 674)

                ];
                 
                for(i in 0...5){
                    var obj = new FlxObject(positions[i].x,positions[i].y,16,16);
                    obj.ID = i;
                    triggerObjects.add(obj);


                }
                 zoneText = new FlxText(1136,17, 0, '', 29);
                zoneText.font = 'assets/fonts/Minecraftia-Regular.ttf';
                zoneText.antialiasing = false;
                zoneText.cameras = [overlayCamera];
                triggerObjects.add(zoneText);
             

                case 'level2-uppermines':
                    var colPos:Array<FlxPoint>=[new FlxPoint(896,289), new FlxPoint(896,305)];
                    if(currentProgress<40){
                    elsen = new DaNpc(816,288, 'elsenMiner');
                    elsen.ID = 88;
                    elsen.coolRange = 30;
                    elsen.dir = 'down';
                    elsen.immovable = true;
                    elsen.offset.set(0,6);

                    collidableObjects.add(elsen);
                    }

                  
                    switch(currentProgress){
                        
                        case 27:
                            for(i in 0...2){
                                var obj = new CoolBox(colPos[i].x, colPos[i].y, 'Lima1');
                                obj.behaviour = Static;
                                obj.immovable = true;

                                obj.ID = 55;
                                collidableObjects.add(obj);
                            }
                        
                        case 25:
                            startDedanCutscene();
                           
                        
                    }
            case 'level2-teleport':

      
            var positions:Array<FlxPoint>=[
                new FlxPoint(400, 192),
                new FlxPoint(400, 240),
                new FlxPoint(560, 192),
                new FlxPoint(560, 240)
            ];
           

            if(currentProgress<40){
                for(i in 0...4)
                    {
                        var box = new CoolBox(positions[i].x, positions[i].y, 'CoolBoxes green box idle', 'CoolBoxes');
                        box.behaviour = Static;
                        box.ID = i;
                        box.alpha = 0.7;
                        box.offset.set(-3,5);
                        collidableObjects.add(box);
                    }
            }
           

                var red = new CoolBox(752, 336, 'CoolBoxes red save idle', 'CoolBoxes');
                
                red.immovable = true;
                red.behaviour = Static;
                red.offset.set(-3,5);

                collidableObjects.add(red);

               
              
            
                if(cowPets>=1000){
                    pancat = new DaNpc(475,73, 'pancat');
                    pancat.immovable = true;
                    pancat.coolRange = 40;
                    pancat.dir = 'down';
                    pancat.ID = 103;
                    collidableObjects.add(pancat);
                }
                
                case 'level2-traindamien':
                    var Arrowpositions:Array<FlxPoint>=[
                        new FlxPoint(610, 489),
                        new FlxPoint(657, 489)
                    ];
                    var entrances:Array<FlxPoint>=[
                        new FlxPoint(656, 528),
                        new FlxPoint(608, 528)
                    ];
                    for(i in 0...2){
                        var arrow = new CoolBox(Arrowpositions[i].x, Arrowpositions[i].y, 'arrow idle', 'SomeObjects', Arrow);
                        
                        triggerObjects.add(arrow);
                    }

                    for(i in 0...2){
                        var trainEntrance = new FlxObject(entrances[i].x,entrances[i].y, 16,16);
                        trainEntrance.ID = 1001;
                        triggerObjects.add(trainEntrance);
                    }
            case 'level2-trainelsen':
                var Arrowpositions:Array<FlxPoint>=[
                    new FlxPoint(672, 538),
                    new FlxPoint(625, 538)
                ];
                var entrances:Array<FlxPoint>=[
                    new FlxPoint(624, 592),
                    new FlxPoint(672, 592)
                ];
                for(i in 0...2){
                    var arrow = new CoolBox(Arrowpositions[i].x, Arrowpositions[i].y, 'arrow idle', 'SomeObjects', Arrow);
                    
                    triggerObjects.add(arrow);
                }
                for(i in 0...2){
                    var trainEntrance = new FlxObject(entrances[i].x,entrances[i].y, 16,16);
                    trainEntrance.ID = 1001;
                    triggerObjects.add(trainEntrance);
                }

                if(currentProgress==100 && cowPets<1000){
                     pancat = new DaNpc(510,606, 'pancat');
                    pancat.immovable = true;
                    pancat.coolRange = 40;
                    pancat.dir = 'right';
                    pancat.ID = 103;
                    collidableObjects.add(pancat);
                }
                trace('hiiii train hiii');
            case 'level1-unlockedzone':
                var positions:Array<FlxPoint>=[
                    new FlxPoint(672, 832),
                    new FlxPoint(672, 976),
                    new FlxPoint(864, 832),
                    new FlxPoint(864, 976)
                ];
                for(i in 0...4)
                    {
                        var box = new CoolBox(positions[i].x, positions[i].y, 'CoolBoxes yellow box idle', 'CoolBoxes');
                        box.behaviour = Static;
                        box.ID = i;
                        box.alpha = 0.7;
                        box.offset.set(-3,5);
                        collidableObjects.add(box);
                    }

                    var red = new CoolBox(768, 896, 'CoolBoxes red save idle', 'CoolBoxes');
                    red.offset.set(-3,5);

                    red.immovable = true;
                    red.behaviour = Static;
                    collidableObjects.add(red);


                    switch(currentProgress){
                        case 20:
                      
                            var obj = new FlxObject(768, 952, 16, 16);
                            obj.ID = 100;
                            triggerObjects.add(obj);
                      
                    }
                    case 'level2-upperminesinterior':
                   

                    if(zacharieProgress == 30 && myInventory.findItemByName("Zacharie's Bag")==null){
                        var bag = new FlxSprite(494,665).loadGraphic(Paths.image('zachStuff/zachBag','preload'));
                        bag.antialiasing = false;
                        bag.immovable = true;
                        bag.ID = 421;
                        collidableObjects.add(bag);

                    }

                        if(currentProgress<40){
                            var elsen = new DaNpc(592,608, 'elsen');
                            elsen.ID = 87;
                            elsen.coolRange = 30;
                            elsen.dir = 'down';
                            elsen.immovable = true;
                 
                            elsen.offset.set(0,6);
                            collidableObjects.add(elsen);

                            var elsenMiner = new DaNpc(640,624, 'elsenMiner');
                            elsenMiner.ID = 86;
                            elsenMiner.coolRange = 30;
                            elsenMiner.dir = 'down';
                            elsenMiner.immovable = true;
                            elsenMiner.offset.set(0,6);
                            collidableObjects.add(elsenMiner);
                        }
                      
                       

                        var chest = new CoolBox(496, 603, 'purple_chest_', 'SomeObjects', Chest);
                        chest.coolRange = 30;
                        chest.immovable = true;
                        chest.ID = 8000;
                        collidableObjects.add(chest);
    
                      checkOpenedChest(chest);
            case 'level1':
             

                var positions:Array<FlxPoint>=[
                    new FlxPoint(656, 1008),
                    new FlxPoint(656, 1200),
                    new FlxPoint(848, 1008),
                    new FlxPoint(848, 1200)
                ];
                for(i in 0...4)
                    {
                        var box = new CoolBox(positions[i].x, positions[i].y, 'CoolBoxes yellow box idle', 'CoolBoxes');
                        box.behaviour = Static;
                        box.ID = i;
                        box.offset.set(-3,5);
                        box.alpha = 0.7;
                        collidableObjects.add(box);
                    }
                    
                    if(OffMenuState.currentYear!=2008){
                        var chest = new CoolBox(610, 507, 'yellow_chest_', 'SomeObjects', Chest);
                        chest.coolRange = 30;
                        chest.immovable = true;
                        chest.ID = 9000;
                        collidableObjects.add(chest);
                        checkOpenedChest(chest);
                        trace('adding chest cuz present');
                    }
                  
                  
                switch(currentProgress){
                    case 100:
                        if(OffMenuState.currentYear!=2008){
                            var finalJudge1 = new DaNpc(753,577, 'Judge', null, true);
                            finalJudge1.alpha = .60;
                            finalJudge1.coolRange = 30;
    
                            finalJudge1.animation.play('down-idle');
                            finalJudge1.ID = 151;
                          
                   
                            finalJudge1.immovable = true;
                            collidableObjects.add(finalJudge1);
                            trace('adding finalJudge1 cuz present');

                        }
                      

                    case 10,15:
                        sittingJudge = new DaNpc(733 -20,409 + 4, 'Judge', null, true);
                       
                        sittingJudge.animation.play('left-idle');
                        sittingJudge.ID = 777;
                      
                        sittingJudge.coolRange = 30;
               
                        sittingJudge.immovable = true;
                        collidableObjects.add(sittingJudge);
                        
                     
                    case 0: 
                        var points:Array<FlxPoint> = [new FlxPoint(760,  697), new FlxPoint(760.5,864.5)];
        
                        var p = new FlxPath(points);
                        
                        npc = new DaNpc(749.00, 677.00, 'Judge', p);
                        add(npc);
        
                        var objPositions:Array<FlxPoint> = [new FlxPoint(736,895), new FlxPoint(752, 895), new FlxPoint(768, 895)];
                        for(i in 0...3){
        
                            var obj = new FlxObject(objPositions[i].x, objPositions[i].y, 16, 16);
                            triggerObjects.add(obj);
                        }
                        
                         
                       
                    
                }
            case 'level1-stairszone':
                if(currentProgress>= 40  && OffMenuState.currentYear!=2008){
           
                    zacharie = new FlxSprite(817,1088);
                    zacharie.frames = Paths.getSparrowAtlas('rpgshit/ZacharieRPG', 'preload');
                    zacharie.animation.addByPrefix('normal', 'ZacharieRPG idle2_', 24, false);
                    zacharie.animation.play('normal');
                    zacharie.offset.set(33,78);

                    zacharie.ID = 220;
                    zacharie.coolRange = 40;
        
                    zacharie.immovable = true;
        
                    zacharie.offset.set(34,71);
                    collidableObjects.add(zacharie);
        
                }
                var objPositions:Array<FlxPoint> = [
                    new FlxPoint(688,1120), 
                    new FlxPoint(736, 1120), 
                    new FlxPoint(784, 1120),

                    new FlxPoint(688, 1152),
                    new FlxPoint(736, 1152),
                    new FlxPoint(784, 1152),

                    new FlxPoint(688, 1184),
                    new FlxPoint(736, 1184),
                    new FlxPoint(784, 1184),

                    new FlxPoint(736, 1216)

                ];
                
                for(i in 0...10){
        

                    var box = new CoolBox(objPositions[i].x, objPositions[i].y, 'Yellow2');
                    box.behaviour = Actionable;
                    box.immovable = true;
                    box.coolRange = 30;
                    box.ID = i;
                    box.offset.set(-2,2);
                    
                    collidableObjects.add(box);
                }
                switch(currentProgress){
                    case 20:
                        var eatingJudge = new FlxSprite(890,1160);
                        eatingJudge.frames = Paths.getSparrowAtlas('rpgshit/JudgeRPG','preload');
                         eatingJudge.animation.addByPrefix('eat', 'JudgeRPG idle', 7, true);
         
                        eatingJudge.animation.play('eat');
                        eatingJudge.immovable = true;
                         collidableObjects.add(eatingJudge);
                     
                    case 17:
                        var box = new CoolBox(898, 1105, 'Yellow1');
                    box.behaviour = Static;
                    box.immovable = true;

                   box.ID = 666;
                   
                    
                    collidableObjects.add(box);

                   var eatingJudge = new FlxSprite(890,1160);
                   eatingJudge.frames = Paths.getSparrowAtlas('rpgshit/JudgeRPG','preload');
                    eatingJudge.animation.addByPrefix('eat', 'JudgeRPG idle', 7, true);
    
                   eatingJudge.animation.play('eat');
                   eatingJudge.immovable = true;
                    collidableObjects.add(eatingJudge);
                }
            case 'level1-puzzlesneak':
                var objPositions:Array<FlxPoint> = [
                    new FlxPoint(736.33,1168.00), 
                    new FlxPoint(752.33, 1168.00), 
                    new FlxPoint(768.33, 1168.00)

                ];
                for(i in 0...3){
                    var obj = new FlxObject(objPositions[i].x, objPositions[i].y, 16, 16);
                    obj.coolRange = 20;
                    obj.immovable = true;
                    collidableObjects.add(obj);

                }
            default:
        }

      
      
    }
    private function calculateDistance(obj1:FlxObject, obj2:FlxObject): Float {
        // Obtiene las coordenadas de los objetos
        /*
        var x1: Float =obj1.x ;
        var y1: Float = obj1.y;
        var x2: Float = obj2.x ;
        var y2: Float = obj2.y;
       
        */
            var x1 = obj1.getMidpoint().x;
            var y1 = obj1.getMidpoint().y;
            var x2 = obj2.getMidpoint().x;
            var y2 = obj2.getMidpoint().y;
        
      

        // Calcula la diferencia en las coordenadas
        var dx: Float = x2 - x1;
        var dy: Float = y2 - y1;

        // Calcula la distancia utilizando el teorema de Pitágoras
        var distance: Float = Math.sqrt(dx * dx + dy * dy);

        return distance;
    }
    var shit:Bool = true;
    public function checkRange( object:FlxObject, jugador:FlxObject,?range:Float = 15):Bool {
         // Define el rango de interacción de tu objeto
        
        // Calcula la distancia entre el centro del objeto y el jugador
        var point:FlxPoint;
       

       
        var distancia:Float = calculateDistance(object, jugador);
      

        
        // Comprueba si la distancia está dentro del rango permitido
        if (distancia <= range) {
            return true; // El jugador está dentro del rango
        } else {
            return false; // El jugador está fuera del rango
        }
    }
    function hitBoxHelper(player:FlxSprite){
        var left=FlxG.keys.pressed.LEFT;
        var right=FlxG.keys.pressed.RIGHT;
        var up=FlxG.keys.pressed.UP;
        var down=FlxG.keys.pressed.DOWN;

        if(FlxG.keys.justPressed.X){
            shit = !shit;
        }
        if(shit){
            if(FlxG.keys.pressed.Q){
                player.width += 0.1;
            }
            if(FlxG.keys.pressed.E){
                player.width  -= 0.1;

            }
        }
        
        else{
            if(FlxG.keys.pressed.Q){
                player.height += 0.1;

            }
            if(FlxG.keys.pressed.E){
                player.height -= 0.1;

    
            }
        }
        if(left)
            {
                player.offset.x += 1;

            }
            if(right)
                {
                    player.offset.x -= 1;

                }
                if(up)
                    {
                        player.offset.y += 1;

                    }
                    if(down)
                        {
                            player.offset.y -= 1;

                        }
        FlxG.watch.addQuick('playerShitOff', '${player.offset.x}||${player.offset.y}');
        FlxG.watch.addQuick('playerShitWH', '${player.width}||${player.height}');

    }
    var mapIsLoaded:Bool = false;
    var camFocus:String = 'player';
    var numimi:FlxPoint = new FlxPoint(0,0);
    function teleportHelper(){
        var left=FlxG.keys.pressed.LEFT;
        var right=FlxG.keys.pressed.RIGHT;
        var up=FlxG.keys.pressed.UP;
        var down=FlxG.keys.pressed.DOWN;
        if(left)
            {
                numimi.x-=1;
            }
            if(right)
                {
                    numimi.x+=1;

                }
                if(up)
                    {
                        numimi.y-=1;

                    }
                    if(down)
                        {
                            numimi.y+=1;

                        }
         FlxG.watch.addQuick('numimi', '${numimi.x}||${numimi.y}');

         //coolteleport.setPosition(player.x+numimi.x,player.y+numimi.y);
         //-35,-103
    }
    var saveSpr:FlxSprite;
    override  function update(elapsed:Float) {
        if(coolShader!=null){
            coolShader.update(elapsed);
        }
        super.update(elapsed);

        
        
        switch(player.dir){
            case 'right':
                ray.x = player.x + 16; 
                ray.y = player.y;
            case 'left': 
                ray.x = player.x - 16; 
                ray.y=player.y;
            case 'up': 
                ray.y = player.y - 16;
                ray.x = player.x;
            case 'down':
                ray.y = player.y + 16;
                ray.x = player.x;

         }
        #if debug
   
        if(FlxG.keys.justPressed.ALT){
            cowPets = 999;
        }
        FlxG.watch.addQuick('playerCanMove',player.canMove);
        FlxG.watch.addQuick('playerPos','X:${player.x} Y:${player.y}');
        FlxG.watch.addQuick('camFocus',camFocus);

     
        #end
     
        
       //trace('updating');
        switch(camFocus){
        case 'player':
            camFollow.y = player.getGraphicMidpoint().y -20;
           
         
            //camFollow.x = player.getGraphicMidpoint().x;
            switch(curMap){
                default:
                    camFollow.x = player.getGraphicMidpoint().x;
                case 'level4japhetzone':
                    camFollow.x =  658;

            }

        case 'playerBattle':
            camFollow.y = player.getGraphicMidpoint().y;
           
            camFollow.x = player.getGraphicMidpoint().x;

        case 'npc':
            camFollow.y = npc.getGraphicMidpoint().y;

        case 'dedan':
            camFollow.y = dedan.getGraphicMidpoint().y;
            camFollow.x = dedan.getGraphicMidpoint().x;


        case 'elsen':
            camFollow.y = elsen.getGraphicMidpoint().y;
            camFollow.x = elsen.getGraphicMidpoint().x + 20;

        case 'none': 

          
        }
     

        
    
        if(FlxG.keys.justPressed.ESCAPE && player.canMove && !player.autoPilot){
            //FlxG.switchState(new MainMenuState());
            pause();
        }
  
        FlxG.camera.follow(camFollow);


        FlxG.watch.addQuick('curmap', curMap);
        FlxG.watch.addQuick('progress', currentProgress);
      
       
       
 

        if (level.collideWithLevel(player)||FlxG.collide(collidableObjects, player))
            {
                // Resetting the movement flag if the player hits the wall
                // is crucial, otherwise you can get stuck in the wall
                player.moveToNextTile = false;
                trace('im colliding');
            }
        if(curMap=='nothing'){
            if(FlxG.collide(coolBounds , player)){
                player.moveToNextTile = false;

                trace('im colliding');
            }
            //FlxG.collide(coolBounds , player);
           

        }

      
        
        
        
        checkMC();
        collidableObjects.sort(FlxSort.byY, FlxSort.ASCENDING);
    }
    
    public static var lastAnim:String;
    public static var lastMap:String;
    function enterBattle(week:Int, progress:Int, rival:String='Judge'){
     
        MapTestState.rival = rival;
        camFocus = 'none';
        FlxTween.tween(camFollow, {y:camFollow.y + 10}, 0.3);

        FlxG.sound.play(Paths.sound('enterbattle', 'preload'));

        FlxG.camera.flash(FlxColor.WHITE, 0.2, function(){
            FlxG.camera.flash(FlxColor.WHITE, 0.2, function(){
            
                FlxTween.tween(FlxG.camera, {zoom:50}, 0.8, {onComplete:function(_){
                    wentoPs = true;
                    lastKnownPos.set(player.x, player.y);
                    lastAnim = player.animation.curAnim.name;
                    switch(rival){
                        case 'Hugo':
                            lastMap = 'theroomPurified';

                        default:
                            lastMap = curMap;

                    }
                    FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function(){
                        PlayState.setStoryWeek(weekData[week],1);
                  
                        LoadingState.loadAndSwitchState(new PlayState(), true);
                  
                    currentProgress = progress;
                    });
                    
                }});
            });
        });
    }
    private var paused:Bool = false;
    var canSave:Bool = true;
    var lockTimer:FlxTimer;
    var  Deciding:Bool = false;
    public static var lastKnownPos:FlxPoint = new FlxPoint();
    var curCode:String = '';
   function startJaphetCutscene(){
    player.autoPilot = true;
    player.path = new FlxPath([new FlxPoint(688, 128)]);
    player.path.autoCenter=false;

    player.path.axes = Y;
    player.path.start(null, 100, FORWARD);
    player.path.onComplete = function(_){
        player.path.cancel();
        player.path = new FlxPath([new FlxPoint(672, 128)]);
        player.path.autoCenter=false;

        player.path.axes = X;
        player.path.start(null, 100, FORWARD);
        player.path.onComplete=function(_){
            player.path.cancel();
            trace('completed path lol');
            
            var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/japhetDialogue')));

            var dialogue = new OffDialogue(dialoguee, Upper);
            dialogue.box.alpha = .70;
            dialogue.cameras = [camHUD];
            add(dialogue);
            dialogue.finishThing = function(){

                enterBattle(3,45, 'Japhet');
            }
        }

    }
   }

    function pause(){
		if(subState!=null)return;
		persistentUpdate = false;
		persistentDraw = false;
        openSubState(new OffPauseSubState());
	}
    function coolSave(opt:CoolDecision){

            CoolDecision.noquis = 0;
            var clonedChest = new Array<Int>();

            for (cloned in openedChest) {
                clonedChest.push(cloned);
            }
        var saveStuff:SaveData = {
            batterPos: player.getPosition(),
            batterName: NameSelectionState.completeName,
            progress: currentProgress,
            maxHealth: maxHealth,
            curHealth: curHealth,
            playerLevel: playerLevel,
            myInventory: myInventory.clone(),
            currentMap: curMap,
            openedChest: clonedChest,
            elsenInteractions: elsenInteractions,
            skin: skin,
            zacharieProgress: zacharieProgress,
            cowPets: cowPets
        }
        OffSaveGame.save(saveStuff);
        player.canMove =true;

            trace('saved bullshit');
            saveSpr = new FlxSprite(1061,668);
            saveSpr.frames = Paths.getSparrowAtlas('save', 'preload');
            saveSpr.cameras = [camHUD];
            saveSpr.scale.set(5,5);
            saveSpr.alpha = 0;
            saveSpr.animation.addByPrefix('idle', 'save SavingAnim', 7, true);
            saveSpr.animation.play('idle');
            add(saveSpr);

            FlxTween.tween(saveSpr, {alpha:1}, 0.5);
            new FlxTimer().start(4, function(_){
                FlxTween.tween(saveSpr, {alpha:0}, 0.5, {onComplete:function(_){
                    saveSpr.destroy();
                    CoolDecision.noquis = 999999;

                }});
              

            });
        
    }
    var doShitOnce:Bool = false;
    function startQueenCutscene(){
        player.autoPilot = true;
        player.path = new FlxPath([new FlxPoint(656, 176)]);
        player.path.autoCenter=false;

        player.path.start(null, 100, FORWARD);
        player.path.onComplete = function(_){
            player.path.cancel();
            
            var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/queenDialogue')));

            var dialogue = new OffDialogue(dialoguee, Bottom);
            dialogue.box.alpha = .70;
            dialogue.cameras = [camHUD];
            add(dialogue);

            dialogue.finishThing = function(){
                enterBattle(5,60, 'Queen');

            }
        }
    }
    function startLastJudgeBatterCutscene(){
        player.autoPilot = true;
        player.path = new FlxPath([new FlxPoint(640,80)]);
        player.path.autoCenter=false;

        player.path.start(null,100, FORWARD);
        player.path.onComplete=function(_){
            player.path.cancel();

            trace('cancel path');

            new FlxTimer().start(0.4, function(_){
           
                var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/judgeTalkstoBatterlastime')));

                var dialogue = new OffDialogue(dialoguee, Bottom);
                dialogue.box.alpha = .70;
                dialogue.cameras = [camHUD];
                add(dialogue);

                var judge = new DaNpc(640,272, 'Judge');
                add(judge);
                judge.path = new FlxPath([new FlxPoint(judge.x, 128)]);
                judge.path.autoCenter=false;

                judge.path.axes = Y;
                judge.path.start(null, 100, FORWARD);
                judge.path.onComplete=function (_){
                        judge.path.cancel();
                        player.dir = 'down';

                }
                dialogue.finishThing = function(){
    
                    var decision = new FinalDecision(0,0);
                    decision.cameras = [camHUD];
                    add(decision);

                    decision.finishThing = function(){
                        switch(decision.curSelection){
                            case 0:
                                trace('ill help batter');
                                enterBattle(8, 90, 'FinalJudge');
                            case 1:
                            trace('ill help judge');
                        

                            enterBattle(7, 90, 'Batter');

                        }
                    }
                    
                }
            });
            

        }
    }
    var banOption:Int = 99999;
    public static var prevHealthStats:FlxPoint = new FlxPoint(0,0);
    function checkMC(){
        if(triggersMap.get(curMap)!=null)
            for(trigger in triggersMap.get(curMap)){
                if (FlxG.overlap(player, trigger))
                    {
                       if(player.canMove){
                        player.canMove = false;
                        
                           
                            collidableObjects.remove(player);

                            remove(collidableObjects);
                            remove(triggerObjects);
 
                            remove(ray);

                            curSpawn = trigger.nextSpawn;
     
                            trace('i wanna get in');
                         
                            switchMap(trigger.warpsTo);
                             add(collidableObjects);
                            add(triggerObjects);
                            collidableObjects.add(player);   
                            add(ray);
                            add(level.aboveLayer);

                           

                           break;
                       }
            
                    }
            }

        for(o in collidableObjects){
            if(checkRange(o, player, o.coolRange) && FlxG.keys.justPressed.ENTER && player.canMove && !Deciding)
                //postGame
            /*
                if(o.ID == 151 && currentProgress == 100){
                    switch(curMap){
                        case 'level1':
                            player.canMove = false;
                              var options = new CoolDecision(['Yes', 'No'], Bottom, 'Would you like to replay Judgement?');
                        
                                options.box.alpha = .70;
                                options.cameras = [camHUD];
    
                                add(options);
                                options.finishThing = function(){
                                    switch(options.curSel){
                                        case 0:
                                            enterBattle(0, 100, 'Judge');
                                            //                                            enterBattle(0,15, 'Judge');

                                        case 1:

                                    }
                                    new FlxTimer().start(0.1, function(_){
                                        player.canMove = true;

                                    });
                                }
                        case 'level3mines':
                            player.canMove = false;
                              var options = new CoolDecision(['Yes', 'No'], Bottom, 'Would you like to replay Spectral-Curveball?');
                        
                                options.box.alpha = .70;
                                options.cameras = [camHUD];
    
                                add(options);
                                options.finishThing = function(){
                                    switch(options.curSel){
                                        case 0:
                                            enterBattle(1, 100, 'Ghost');
                                            //                                            enterBattle(0,15, 'Judge');

                                        case 1:

                                    }
                                    new FlxTimer().start(0.1, function(_){
                                        player.canMove = true;

                                    });
                                }
                        case 'level3dedanoffice':
                            player.canMove = false;
                            var options = new CoolDecision(['Yes', 'No'], Bottom, 'Would you like to replay Iron-Fist?');
                      
                              options.box.alpha = .70;
                              options.cameras = [camHUD];
  
                              add(options);
                              options.finishThing = function(){
                                  switch(options.curSel){
                                      case 0:
                                          enterBattle(2, 100, 'Dedan');
                                          //                                            enterBattle(0,15, 'Judge');

                                      case 1:

                                  }
                                  new FlxTimer().start(0.1, function(_){
                                      player.canMove = true;

                                  });
                              }
                        case 'level4japhetzone':
                            player.canMove = false;
                            var options = new CoolDecision(['Yes', 'No'], Bottom, 'Would you like to replay Hellish-Hiems?');
                      
                              options.box.alpha = .70;
                              options.cameras = [camHUD];
  
                              add(options);
                              options.finishThing = function(){
                                  switch(options.curSel){
                                      case 0:
                                          enterBattle(3, 100, 'Japhet');
                                          //                                            enterBattle(0,15, 'Judge');

                                      case 1:

                                  }
                                  new FlxTimer().start(0.1, function(_){
                                      player.canMove = true;

                                  });
                              }
                        case 'level5enochzone':
                            player.canMove = false;
                            var options = new CoolDecision(['Yes', 'No'], Bottom, 'Would you like to replay A-Furia-Do-Colosso?');
                      
                              options.box.alpha = .70;
                              options.cameras = [camHUD];
  
                              add(options);
                              options.finishThing = function(){
                                  switch(options.curSel){
                                      case 0:
                                          enterBattle(4, 100, 'Enoch');
                                          //                                            enterBattle(0,15, 'Judge');

                                      case 1:

                                  }
                                  new FlxTimer().start(0.1, function(_){
                                      player.canMove = true;

                                  });
                              }
                        case 'level6queenzone':
                            player.canMove = false;
                            var options = new CoolDecision(['Yes', 'No'], Bottom, 'Would you like to replay Melancholy-Symphony?');
                      
                              options.box.alpha = .70;
                              options.cameras = [camHUD];
  
                              add(options);
                              options.finishThing = function(){
                                  switch(options.curSel){
                                      case 0:
                                          enterBattle(5, 100, 'Queen');
                                          //                                            enterBattle(0,15, 'Judge');

                                      case 1:

                                  }
                                  new FlxTimer().start(0.1, function(_){
                                      player.canMove = true;

                                  });
                              }
                        case 'theroomPurified':
                        player.canMove = false;
                        var options = new CoolDecision(['Yes', 'No'], Bottom, 'Would you like to replay Hugo?');
                  
                          options.box.alpha = .70;
                          options.cameras = [camHUD];

                          add(options);
                          options.finishThing = function(){
                              switch(options.curSel){
                                  case 0:
                                      enterBattle(6, 100, 'Hugo');
                                      //                                            enterBattle(0,15, 'Judge');

                                  case 1:

                              }
                              new FlxTimer().start(0.1, function(_){
                                  player.canMove = true;

                              });
                          }
                        case 'purifiedhallway':
                        player.canMove = false;
                        var options = new CoolDecision(['No-Way-Back', 'Ascendants-Echo'], Bottom, 'Which song you want to replay?');
                  
                          options.box.alpha = .70;
                          options.cameras = [camHUD];

                          add(options);
                          options.finishThing = function(){
                              switch(options.curSel){
                                  case 0:
                                      enterBattle(8, 100, 'Judge');
                                      //                                            enterBattle(0,15, 'Judge');

                                  case 1:
                                    enterBattle(7, 100, 'Batter');

                              }
                              new FlxTimer().start(0.1, function(_){
                                  player.canMove = true;

                              });
                          }
                    }
                }
                */
                switch(curMap){
                  
                    case 'level2-trainelsen':
                        if(o.ID == 103){
                            switch(cowPets){
                                case 1000:
                                    player.canMove = false;
                                    var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/pancatPrev')));

                                    var dialogue = new OffDialogue(dialoguee, Bottom);
                                    dialogue.box.alpha = .70;
                                    dialogue.cameras = [camHUD];
                                    add(dialogue);
                                    dialogue.finishThing = function(){
                                      
                                        pancat.path = new FlxPath([new FlxPoint(630, pancat.y)]);
                                        pancat.path.axes = X;
                                        pancat.path.start(null, 80, FORWARD);
                                        pancat.path.onComplete = function(_){
                                            pancat.path.cancel();
                                            pancat.path = new FlxPath([new FlxPoint(pancat.x, 697)]);
                                            pancat.path.axes = Y;
                                            pancat.path.start(null, 80, FORWARD);
                                            pancat.path.onComplete = function(_){
                                                pancat.path.cancel();

                                                collidableObjects.remove(pancat, true);


                                                new FlxTimer().start(0.1,function(_){
                                                    player.canMove = true;
                
                                                });
                                            }

                                        }
                                      
                                    }
                                default:
                                player.canMove = false;
                                var dialogue = new OffDialogue(['-pancat-Mooooh Mooohh.', '-batter-...'], Bottom);
                                dialogue.box.alpha = .70;
                                dialogue.cameras = [camHUD];
                                add(dialogue);
                                dialogue.finishThing = function(){
    
                                    var options = new CoolDecision(['Yes', 'No'], Bottom, 'Would you like to pet the cow?');
                          
                                    options.box.alpha = .70;
                                    options.cameras = [camHUD];
          
                                    add(options);
                                    options.finishThing = function(){
                                        switch(options.curSel){
                                            case 0:
                                              
                                                FlxG.sound.play(Paths.sound('pancatTalks', 'preload'));
                                                cowPets++;
                                                var pat = new OffDialogue([(cowPets<=1 ?'-narrator-You have pet the cow ${cowPets} time out of 1000.':'-narrator-You have pet the cow ${cowPets} times out of 1000.' )], Bottom);
                                                pat.box.alpha = .70;
                                                pat.cameras = [camHUD];
                                                add(pat);
                                                pat.finishThing = function(){
                                                    new FlxTimer().start(0.1,function(_){
                                                        player.canMove = true;
                    
                                                    });
                                                }
                                               
                                            case 1:
                                                new FlxTimer().start(0.1,function(_){
                                                    player.canMove = true;
                
                                                });
    
                                        }
                                      
                                    }
                                  
                                }
                            }
                            
                        }
                    case 'theroomPurified':
                        if(o.ID == 151 && currentProgress == 100){
                            player.canMove = false;
                            var options = new CoolDecision(['Yes', 'No'], Bottom, 'Would you like to replay Hugo?');
                      
                              options.box.alpha = .70;
                              options.cameras = [camHUD];
    
                              add(options);
                              options.finishThing = function(){
                                  switch(options.curSel){
                                      case 0:
                                          enterBattle(6, 100, 'Hugo');
                                          //                                            enterBattle(0,15, 'Judge');
    
                                      case 1:
    
                                  }
                                  new FlxTimer().start(0.1, function(_){
                                      player.canMove = true;
    
                                  });
                              }
                        }
                    case 'level6queenprev':
                        if(o.ID == 888)
                            {
                                switch(currentProgress){
                                    case 50:
                                      
                                            player.canMove = false;
                                            Deciding = true;
                    
                                            var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/queenslock')));
                    
                                            var dialogue = new OffDialogue(dialoguee, Bottom);
                                            dialogue.box.alpha = .70;
                                            dialogue.cameras = [camHUD];
                                            add(dialogue);
                                            dialogue.finishThing=function(){
                                                currentProgress = 53;
                                                player.canMove = true;
                                                new FlxTimer().start(0.7, function(_){
                                                    Deciding = false;
                                                    
                    
                                                });
                    
                                                new FlxTimer().start(20, function(_){
                                                    trace('and now batter talks to the player');
                                                    player.canMove = false;
                                                    player.dir = 'down';
                                                    var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/batterTalksAboutKey')));
                    
                                                    var dialogue = new OffDialogue(dialoguee, Bottom);
                                                    dialogue.box.alpha = .70;
                                                    dialogue.cameras = [camHUD];
                                                    add(dialogue);
                                                    dialogue.finishThing=function(){
                                                        player.canMove = true;
                                                        currentProgress = 55;

                
                                                    }
                
                                                });
                
                                            }
                                        
                                    default:
                                        if(myInventory.findItemByName('The Key')!=null){

                                            //  teleport('level6queenprev',14444, true);

                                           var sound:FlxSound = new FlxSound();
                                           sound =  FlxG.sound.load(Paths.sound('lockedOpens', 'preload'));
                                           sound.play();
                                            teleport('level6hallway',15555, false, true);

                                          

                                        }
        
                                }
                            }
                      
                        
                      
                            case 'level5enochchase':
                                if(o.ID == 421){
                                    player.canMove = false;

                                    var dialogue = new OffDialogue(["-narrator-You found Zacharie's Inventory Book."], Bottom);
                                    dialogue.box.alpha = .70;
                                    dialogue.cameras = [camHUD];
                                    add(dialogue);
                                    dialogue.finishThing = function(){
                                        player.canMove=true;
                                       myInventory.addItem("Zacharie's Book", 1, 'A book with a list of items',false, true);
    
                                        new FlxTimer().start(0.1, function(_){
                                            player.canMove = true;
        
                                        });
        
                                    }
                                    collidableObjects.remove(o, true);
                                }
                    case 'level2-pasttrainelsen':
                        switch(o.ID){
                            case 421:
                            player.canMove = false;

                            var dialogue = new OffDialogue(["-narrator-You found Zacharie's Mask."], Bottom);
                            dialogue.box.alpha = .70;
                            dialogue.cameras = [camHUD];
                            add(dialogue);
                            dialogue.finishThing = function(){
                                player.canMove=true;
                                myInventory.addItem("Zacharie's Mask", 1, 'Looks like Japhet',false, true);

                                new FlxTimer().start(0.1, function(_){
                                    player.canMove = true;

                                });

                            }
                            collidableObjects.remove(o, true);

                            case 711:
                                player.canMove = false;

                            var dialogue = new OffDialogue(["-elsen-Oh, the m...mines... It takes f...forever to w...walk across the bridge. S...someone should really d...do something to make it faster."], Bottom);
                            dialogue.box.alpha = .70;
                            dialogue.cameras = [camHUD];
                            add(dialogue);
                            dialogue.finishThing = function(){

                                new FlxTimer().start(0.1, function(_){
                                    player.canMove = true;

                                });

                            }
                            case 712:
                                player.canMove = false;

                                var dialogue = new OffDialogue(["-elsenMiner-Um, s...sorry, b...but I can't let you p...pass without an identification. I...I'm really sorry."], Bottom);
                                dialogue.box.alpha = .70;
                                dialogue.cameras = [camHUD];
                                add(dialogue);
                                dialogue.finishThing = function(){
    
                                    new FlxTimer().start(0.1, function(_){
                                        player.canMove = true;
    
                                    });
    
                                }
                            case 713:
                                player.canMove = false;

                                var dialogue = new OffDialogue(["-elsen-They say when the waters stop flowing, it means there's an evil entity nearby."], Bottom);
                                dialogue.box.alpha = .70;
                                dialogue.cameras = [camHUD];
                                add(dialogue);
                                dialogue.finishThing = function(){
    
                                    new FlxTimer().start(0.1, function(_){
                                        player.canMove = true;
    
                                    });
    
                                }

                        }
                    case 'level2-upperminesinterior':
                       
                            if(o.behaviour == Chest&& o.curAnim!='open'){
        
                                o.animation.play('open');
                                player.canMove = false;
                               var dialogue = new OffDialogue(["-narrator-A lucky ticket has been found."], Upper, true);
                               dialogue.box.alpha = .70;
        
                               dialogue.cameras = [camHUD];
                               add(dialogue);
                               dialogue.finishThing = function(){
                               myInventory.addItem('Lucky ticket', 2, 'Restores a moderate amount of health');
                 
        
        
                                   player.canMove = true;
                                   openedChest.push(o.ID);
        
                               }
                            }
                        switch(o.ID){
                            case 421:
                                player.canMove = false;

                                var dialogue = new OffDialogue(["-narrator-You found Zacharie's bag."], Bottom);
                                dialogue.box.alpha = .70;
                                dialogue.cameras = [camHUD];
                                add(dialogue);
                                dialogue.finishThing = function(){
                                    player.canMove=true;
                                   myInventory.addItem("Zacharie's Bag", 1, 'A bag full of goods',false, true);

                                    new FlxTimer().start(0.1, function(_){
                                        player.canMove = true;
    
                                    });
    
                                }
                                collidableObjects.remove(o, true);
                            case 87:
                                player.canMove = false;
                                Deciding = true;

                                var dialogue = new OffDialogue(['-elsen-A lot of workers died...'], Bottom);
                                dialogue.box.alpha = .70;
                                dialogue.cameras = [camHUD];
                                add(dialogue);
                                dialogue.finishThing = function(){
                                    player.canMove=true;
                                    #if debug
                                   myInventory.addItem('Supervisor Suit', 1, 'Makes you look good',true);

                                    #end
                                    
                                   elsenInteractions++;

                                  
                                    new FlxTimer().start(0.7, function(_){
                                        Deciding = false;
    
                                    });
    
                                }
                            case 86:
                                player.canMove = false;
                                Deciding = true;

                                var dialogue = new OffDialogue(['-elsenMiner-I...I dont...Wanna go back to the smoke mines...'], Bottom);
                                dialogue.box.alpha = .70;
                                dialogue.cameras = [camHUD];
                                add(dialogue);
                                dialogue.finishThing = function(){
                                    player.canMove=true;
                                    elsenInteractions++;
                                  
                                    new FlxTimer().start(0.7, function(_){
                                        Deciding = false;
    
                                    });
    
                                }
                        }
                    
                    case 'level2-uppermines':
                        if(o.ID == 88){
                            if(elsenInteractions>=500 && myInventory.findItemByName('Supervisor Suit')==null && currentProgress>27){
                                player.canMove=false;
                                Deciding = true;

                                var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/batterReceivesSuit')));

                                var dialogue = new OffDialogue(dialoguee, Bottom);
                                dialogue.box.alpha = .70;
                                dialogue.cameras = [camHUD];
                                add(dialogue);
                                dialogue.finishThing = function(){
                                    myInventory.addItem('Supervisor Suit', 1, 'Makes you look good',true);

                                    var dialogue = new OffDialogue(['-narrator-You have received a Supervisor suit'], Bottom, true);
                                    dialogue.box.alpha = .70;
                                    dialogue.cameras = [camHUD];
                                    add(dialogue);
                                    dialogue.finishThing = function(){
                                        player.canMove=true;

                                        new FlxTimer().start(0.7, function(_){
                                            Deciding = false;

                                        });
                                    }

                                }

                            }else{
                                switch(currentProgress){
                                    case 30:
                                        player.canMove=false;
                                        Deciding = true;
                                        var dialogue = new OffDialogue(['-elsenMiner-Please...Uh...Get rid of the ghosts.'], Bottom);
                                        dialogue.box.alpha = .70;
                                        dialogue.cameras = [camHUD];
                                        add(dialogue);
                                        dialogue.finishThing = function(){
                                            elsen.dir = 'right';
                                            player.canMove=true;
                                            elsenInteractions++;
    
                                            new FlxTimer().start(0.7, function(_){
                                                Deciding = false;
    
                                            });
    
                                        }
                                    case 27:
                                        switch(player.dir){
                                            case 'left':
                                                elsen.dir = 'right';
                                            case 'right':
                                                elsen.dir = 'left';
    
                                            case 'down':
                                                elsen.dir = 'up';
    
                                            case 'up':
                                                elsen.dir = 'down';
                                        }
                                        player.canMove=false;
                                        Deciding = true;
                                        var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/batterAndElsenTalkAfterDedan')));
                                        var dialogue = new OffDialogue(dialoguee, Bottom);
                                        dialogue.box.alpha = .70;
                                        dialogue.cameras = [camHUD];
                                        add(dialogue);
                                        dialogue.finishThing = function(){
                                            elsen.dir = 'right';
                                            player.canMove=true;
    
                                            for(o in collidableObjects){
                                                if(o.ID == 55){
                                                    collidableObjects.remove(o, true);
                                                }
                                            }
                                            currentProgress = 30;
                                            new FlxTimer().start(0.7, function(_){
                                                Deciding = false;
    
                                            });
    
                                        }
    
                                }
                            }
                          
                        }
                        case 'level6queenzone':
                            if(o.ID == 151 && currentProgress == 100){
                                player.canMove = false;
                            var options = new CoolDecision(['Yes', 'No'], Bottom, 'Would you like to replay Melancholy-Symphony?');
                      
                              options.box.alpha = .70;
                              options.cameras = [camHUD];
  
                              add(options);
                              options.finishThing = function(){
                                  switch(options.curSel){
                                      case 0:
                                          enterBattle(5, 100, 'Queen');
                                          //                                            enterBattle(0,15, 'Judge');

                                      case 1:

                                  }
                                  new FlxTimer().start(0.1, function(_){
                                      player.canMove = true;

                                  });
                              }
                            }
                            if(o.behaviour == Static){
                                //12222
                                 player.canMove =false;
                                Deciding = true;
                                var dialogue = new OffDialogue(['-narrator-Health points have been restored'], Bottom, true);
                                dialogue.box.alpha = .70;
                                dialogue.cameras = [camHUD];
                                add(dialogue);
                                
                                dialogue.finishThing = function(){
                                    if(curHealth<maxHealth){
                                        curHealth = maxHealth;
                                    }
                                    var options = new CoolDecision(['Save progress', 'The Room', 'Go to previous Location', 'Exit'], Bottom);
                            
                                    options.box.alpha = .70;
                                    options.cameras = [camHUD];
        
                                    add(options);
                                   
                                    options.finishThing = function(){
                                        switch(options.curSel){
                                            case 0:
                                                coolSave(options);
                                                
                                                
          
                                                case 1:
                                                    trace('wooow nothing');
                                                    if(currentProgress<100)
                                                    teleport('theroom',16666, true);
                                                    else if(currentProgress>=100)
                                                        teleport('theroomPurified',16666, true);

                                                  
                                                case 2:
                                                    teleport('level5enochzone',13333, true);

                
                                                case 3:
                                                    player.canMove =true;

                                                    trace('lol');
                                        }
                                        new FlxTimer().start(0.7, function(_){
                                            Deciding = false;
        
                                        });
        
                                     
                                    }

                                }
                            }
                        case 'level5enochzone':
                            if(o.ID == 151 && currentProgress == 100){
                                player.canMove = false;
                                var options = new CoolDecision(['Yes', 'No'], Bottom, 'Would you like to replay A-Furia-Do-Colosso?');
                          
                                  options.box.alpha = .70;
                                  options.cameras = [camHUD];
      
                                  add(options);
                                  options.finishThing = function(){
                                      switch(options.curSel){
                                          case 0:
                                              enterBattle(4, 100, 'Enoch');
                                              //                                            enterBattle(0,15, 'Judge');
    
                                          case 1:
    
                                      }
                                      new FlxTimer().start(0.1, function(_){
                                          player.canMove = true;
    
                                      });
                                  }
                            }
                            if(o.behaviour == Static){
                                //12222
                                 player.canMove =false;
                                Deciding = true;
                                var dialogue = new OffDialogue(['-narrator-Health points have been restored'], Bottom, true);
                                dialogue.box.alpha = .70;
                                dialogue.cameras = [camHUD];
                                add(dialogue);
                                
                                dialogue.finishThing = function(){
                                    if(curHealth<maxHealth){
                                        curHealth = maxHealth;
                                    }
                                    var options = new CoolDecision(['Save progress', 'Go to guardian location', 'Go to previous Location', 'Exit'], Bottom);
                            
                                    options.box.alpha = .70;
                                    options.cameras = [camHUD];
        
                                    add(options);
                                
                                    options.finishThing = function(){
                                        switch(options.curSel){
                                            case 0:
                                                
                                                    coolSave(options);
                                                 
                                                trace('saved bullshit');
                                                case 1:
                                                    trace('wooow nothing');
                                                    teleport('level6queenprev',14444, true);
                                                  
                                                case 2:
                                                teleport('level4japhetzone',12222, true);

                
                                                case 3:
                                                    player.canMove =true;

                                                    trace('lol');
                                        }
                                        new FlxTimer().start(0.7, function(_){
                                            Deciding = false;
        
                                        });
        
                                     
                                    }

                                }
                            }
                        case 'level4japhetzone':
                            if(o.ID  == 151 && currentProgress == 100){
                                player.canMove = false;
                                var options = new CoolDecision(['Yes', 'No'], Bottom, 'Would you like to replay Hellish-Hiems?');
                          
                                  options.box.alpha = .70;
                                  options.cameras = [camHUD];
      
                                  add(options);
                                  options.finishThing = function(){
                                      switch(options.curSel){
                                          case 0:
                                              enterBattle(3, 100, 'Japhet');
                                              //                                            enterBattle(0,15, 'Judge');
    
                                          case 1:
    
                                      }
                                      new FlxTimer().start(0.1, function(_){
                                          player.canMove = true;
    
                                      });
                                  }
                            }
                            if(o.ID == 220){
                                trace('zach 1');
                                if(!temporal && zacharie.animation.curAnim.name == 'normal'){
                                    player.canMove = false;
                                    var dialogue = new OffDialogue([
                                    '-zacharie-Looks like you have a tough fight ahead, take this', '-narrator-You receveided 2 Lucky Tickets',
                                    '-batter-Thanks.'], Bottom);
                                   dialogue.box.alpha = .70;
                                   dialogue.cameras = [camHUD];
                                   add(dialogue);
                                   dialogue.finishThing = function(){
                                    myInventory.addItem('Lucky ticket', 2, 'Restores a moderate amount of health');

                                        new FlxTimer().start(0.1,function(_){
                                            temporal = true;
                                            player.canMove = true;
                                        });
                                      

                                   }
                                }
                                else{
                                    player.canMove = false;

                                    var dialogue = new OffDialogue([(currentProgress<45 ? '-zacharie-Good Luck':'-zacharieAfter-Good Luck')], Bottom);
                                   dialogue.box.alpha = .70;
                                   dialogue.cameras = [camHUD];
                                   add(dialogue);
                                   dialogue.finishThing = function(){
                                    new FlxTimer().start(0.1,function(_){
                                        player.canMove = true;
                                    });

                                }
                            }
                                
                                
                            }
                            if(o.behaviour == Static){
                                //12222
                                 player.canMove =false;
                                Deciding = true;
                                var dialogue = new OffDialogue(['-narrator-Health points have been restored'], Bottom, true);
                                dialogue.box.alpha = .70;
                                dialogue.cameras = [camHUD];
                                add(dialogue);
                                
                                dialogue.finishThing = function(){
                                    if(curHealth<maxHealth){
                                        curHealth = maxHealth;
                                    }
                                    var options = new CoolDecision(['Save progress', 'Go to guardian location', 'Go to previous Location', 'Exit'], Bottom);
                            
                                    options.box.alpha = .70;
                                    options.cameras = [camHUD];
        
                                    add(options);
                                   
                                    options.finishThing = function(){
                                        switch(options.curSel){
                                            case 0:
                                               
                                                    coolSave(options);
                                                  
                                                trace('saved bullshit');
                                                case 1:
                                                    trace('wooow nothing');
                                                    teleport('level5enochzone',13333, true);
                                                  
                                                case 2:
                                                teleport('level3dedanoffice',11111, true);

                
                                                case 3:
                                                    player.canMove =true;

                                                    trace('lol');
                                        }
                                        new FlxTimer().start(0.7, function(_){
                                            Deciding = false;
        
                                        });
        
                                     
                                    }

                                }
                            }
                            case 'purifiedhallway':
                                if(o.ID == 151 && currentProgress == 100){
                                    player.canMove = false;
                                    var options = new CoolDecision(['No-Way-Back', 'Ascendants-Echo', 'Exit'], Bottom, 'Which song you want to replay?');
                              
                                      options.box.alpha = .70;
                                      options.cameras = [camHUD];
            
                                      add(options);
                                      options.finishThing = function(){
                                          switch(options.curSel){
                                              case 0:
                                                  enterBattle(8, 100, 'Judge');
                                                  new FlxTimer().start(0.1, function(_){
                                                    player.canMove = true;
                  
                                                });
                                                  //                                            enterBattle(0,15, 'Judge');
            
                                              case 1:
                                                enterBattle(7, 100, 'Batter');
                                                new FlxTimer().start(0.1, function(_){
                                                    player.canMove = true;
                  
                                                });
                                            case 2:
                                                new FlxTimer().start(0.1, function(_){
                                                    player.canMove = true;
                  
                                                });
            
                                          }
                                       
                                      }
                                
                                }
                                if(o.behaviour == Static){
                                    //12222
                                     player.canMove =false;
                                    Deciding = true;
                                    var dialogue = new OffDialogue(['-narrator-Health points have been restored'], Bottom, true);
                                    dialogue.box.alpha = .70;
                                    dialogue.cameras = [camHUD];
                                    add(dialogue);
                                    
                                    dialogue.finishThing = function(){
                                        if(curHealth<maxHealth){
                                            curHealth = maxHealth;
                                        }
                                        var options = new CoolDecision(['Save progress',  'Go to previous Location', 'Exit'], Bottom);
                                
                                        options.box.alpha = .70;
                                        options.cameras = [camHUD];
            
                                        add(options);
                                        
                                        options.finishThing = function(){
                                            switch(options.curSel){
                                                case 0:
                                                    
                                                        coolSave(options);
                                                      
                                                    trace('saved bullshit');
                                                    case 1:
                                                        trace('wooow nothing');
                                                        teleport('level6queenprev',14444, true);
                                                      
                                                    case 2:
                                                        player.canMove =true;
    
                                                        trace('lol');
    
                    
                                                 
                                                       
                                            }
                                            new FlxTimer().start(0.7, function(_){
                                                Deciding = false;
            
                                            });
            
                                         
                                        }
    
                                    }
                                }
                        case 'level3dedanoffice':
                            if(o.ID == 151 && currentProgress == 100){
                                player.canMove = false;
                                var options = new CoolDecision(['Yes', 'No'], Bottom, 'Would you like to replay Iron-Fist?');
                          
                                  options.box.alpha = .70;
                                  options.cameras = [camHUD];
      
                                  add(options);
                                  options.finishThing = function(){
                                      switch(options.curSel){
                                          case 0:
                                              enterBattle(2, 100, 'Dedan');
                                              //                                            enterBattle(0,15, 'Judge');
    
                                          case 1:
    
                                      }
                                      new FlxTimer().start(0.1, function(_){
                                          player.canMove = true;
    
                                      });
                                  }
                            }
                            if(o.behaviour == Static){
                                //12222
                                 player.canMove =false;
                                Deciding = true;
                                var dialogue = new OffDialogue(['-narrator-Health points have been restored'], Bottom, true);
                                dialogue.box.alpha = .70;
                                dialogue.cameras = [camHUD];
                                add(dialogue);
                                
                                dialogue.finishThing = function(){
                                    if(curHealth<maxHealth){
                                        curHealth = maxHealth;
                                    }
                                    var options = new CoolDecision(['Save progress', 'Go to guardian location', 'Go to previous Location', 'Exit'], Bottom);
                            
                                    options.box.alpha = .70;
                                    options.cameras = [camHUD];
        
                                    add(options);
                                  
                                    options.finishThing = function(){
                                        switch(options.curSel){
                                            case 0:
                                               
                                                    coolSave(options);
                                            
                                                trace('saved bullshit');
                                                case 1:
                                                    trace('wooow nothing');
                                                    teleport('level4japhetzone',12222, true);
                                                  
                                                case 2:
                                                teleport('level3mines',10111, true);

                
                                                case 3:
                                                    player.canMove =true;

                                                    trace('lol');
                                        }
                                        new FlxTimer().start(0.7, function(_){
                                            Deciding = false;
        
                                        });
        
                                     
                                    }

                                }
                            }
                        case 'level3mines':
                            if(o.ID == 151  && currentProgress == 100){
                                player.canMove = false;
                                var options = new CoolDecision(['Yes', 'No'], Bottom, 'Would you like to replay Spectral-Curveball?');
                          
                                  options.box.alpha = .70;
                                  options.cameras = [camHUD];
      
                                  add(options);
                                  options.finishThing = function(){
                                      switch(options.curSel){
                                          case 0:
                                              enterBattle(1, 100, 'Ghost');
                                              //                                            enterBattle(0,15, 'Judge');
  
                                          case 1:
  
                                      }
                                      new FlxTimer().start(0.1, function(_){
                                          player.canMove = true;
  
                                      });
                                  }
                            }
                            if(o.behaviour == Static){
                                player.canMove =false;
                                Deciding = true;
                                var dialogue = new OffDialogue(['-narrator-Health points have been restored'], Bottom, true);
                                dialogue.box.alpha = .70;
                                dialogue.cameras = [camHUD];
                                add(dialogue);
                                
                                dialogue.finishThing = function(){
                                    if(curHealth<maxHealth){
                                        curHealth = maxHealth;
                                    }
                                    var options = new CoolDecision(['Save progress', 'Go to guardian location', 'Exit'], Bottom);
                            
                                    options.box.alpha = .70;
                                    options.cameras = [camHUD];
        
                                    add(options);
                                  
                                    options.finishThing = function(){
                                        switch(options.curSel){
                                            case 0:
                                              
                                                    coolSave(options);
                                               
                                                trace('saved bullshit');
                                                case 1:
                                                    trace('wooow nothing');
                                                    teleport('level3dedanoffice',11111, true);
                                                  
                
                                                case 2:
                                                    player.canMove =true;

                                                    trace('lol');
                                        }
                                        new FlxTimer().start(0.7, function(_){
                                            Deciding = false;
        
                                        });
        
                                     
                                    }

                                }
                                
                            }    
                            case 'level2-teleport':
                                if(o.ID == 103){
                                    player.canMove = false;
                                    var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/pancatNext')));

                                    var dialogue = new OffDialogue(dialoguee, Bottom);
                                    dialogue.box.alpha = .70;
                                    dialogue.cameras = [camHUD];
                                    add(dialogue);
                                    dialogue.finishThing = function(){
                                        var options = new CoolDecision(['Yes?', 'What?'], Bottom);
                                
                                        options.box.alpha = .70;
                                        options.cameras = [camHUD];
            
                                        add(options);
                                        options.finishThing = function(){
                                            switch(options.curSel){
                                                case 0:
                                                    trace('and now the battle');
                                                    enterBattle(10, 100, 'Cow');

                                                case 1:
                                                    new FlxTimer().start(0.1,function(_){
                                                        player.canMove = true;
                    
                                                    });
                                            }
                                          
                                        }
                                       
                                      
                                    }
                                }
                                if(o.behaviour == Static){
                                    player.canMove =false;
                                    Deciding = true;
        
                                    var dialogue = new OffDialogue(['-narrator-Health points have been restored'], Bottom, true);
                                    dialogue.box.alpha = .70;
                                    dialogue.cameras = [camHUD];
                                    add(dialogue);
        
                                    dialogue.finishThing = function(){
                                        if(curHealth<maxHealth){
                                            curHealth = maxHealth;
                                        }
                                        var options = new CoolDecision(['Save progress', 'Return to the nothingness', 'Exit'], Bottom);
                                
                                        options.box.alpha = .70;
                                        options.cameras = [camHUD];
            
                                        add(options);
                                       
                                        options.finishThing = function(){
                                            switch(options.curSel){
                                                case 0:
                                                  
                                                        coolSave(options);
                                                    
                                                    trace('saved bullshit');
                                                    case 1:
                                                        trace('wooow nothing');
                                                        teleport('nothing',5000, true);
                                                      
                    
                                                    case 2:
                                                        player.canMove =true;
        
                                                        trace('lol');
                                            }
                                            new FlxTimer().start(0.7, function(_){
                                                Deciding = false;
            
                                            });
            
                                         
                                        }
                                    }
                                    
                                }    
                    case 'level1-unlockedzone':
                        if(o.behaviour == Static){
                            player.canMove =false;
                            Deciding = true;

                            var dialogue = new OffDialogue(['-narrator-Health points have been restored'], Bottom, true);
                            dialogue.box.alpha = .70;
                            dialogue.cameras = [camHUD];
                            add(dialogue);

                            dialogue.finishThing = function(){
                                if(curHealth<maxHealth){
                                    curHealth = maxHealth;
                                }
                                var options = new CoolDecision(['Save progress', 'Return to the nothingness', 'Exit'], Bottom);
                        
                                options.box.alpha = .70;
                                options.cameras = [camHUD];
    
                                add(options);
                               
                                options.finishThing = function(){
                                    switch(options.curSel){
                                        case 0:
                                          
                                                coolSave(options);
                                            
                                            trace('saved bullshit');
                                            case 1:
                                                trace('wooow nothing');
                                                teleport('nothing',5000, true);
                                              
            
                                            case 2:
                                                player.canMove =true;

                                                trace('lol');
                                    }
                                    new FlxTimer().start(0.7, function(_){
                                        Deciding = false;
    
                                    });
    
                                 
                                }
                            }
                            
                        }    
                    case 'level1-stairszone':
            

                    if(o.ID == 220){
                        switch(zacharieProgress){
                            case 0:
                                player.canMove=false;

                                var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/zachariexbatterisreal')));
                                var dialogue = new OffDialogue(dialoguee, Bottom);
                                dialogue.box.alpha = .70;
                                dialogue.cameras = [camHUD];
                                add(dialogue);

                                dialogue.finishThing = function(){
                                    new FlxTimer().start(0.1, function(_){
                                        player.canMove=true;
                                        zacharieProgress = 30;
                                        myInventory.addItem('Fortune ticket', 2, 'Restores a large amount of health');
                                    });
                                }
                                
                            case 30:
                                if(myInventory.findItemByName("Zacharie's Bag")!=null){
                                    player.canMove=false;
                                    var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/batterbringsbackbag')));

                                    var dialogue = new OffDialogue(dialoguee, Bottom);
                                    dialogue.box.alpha = .70;
                                    dialogue.cameras = [camHUD];
                                    add(dialogue);
    
                                    dialogue.finishThing = function(){
                                        new FlxTimer().start(0.1, function(_){
                                            player.canMove=true;
                                            zacharieProgress = 50;

                                            myInventory.addItem('Switch', 1, 'Reveal your true self', true);

                                            myInventory.removeItem("Zacharie's Bag");
                                        });
                                    }
                                }
                                
                                else{
                                    player.canMove=false;

                                    var dialogue = new OffDialogue(['-zacharie-Good luck my friend.'], Bottom);
                                    dialogue.box.alpha = .70;
                                    dialogue.cameras = [camHUD];
                                    add(dialogue);
    
                                    dialogue.finishThing = function(){
                                        new FlxTimer().start(0.1, function(_){
                                            player.canMove=true;
    
                                        });
                                    }
                                }
                            case 50:
                            if(currentProgress>=50){
                                player.canMove=false;

                                var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/gofindmacomic')));

                                var dialogue = new OffDialogue(dialoguee, Bottom);
                                dialogue.box.alpha = .70;
                                dialogue.cameras = [camHUD];
                                add(dialogue);
                                dialogue.finishThing = function(){
                                    new FlxTimer().start(0.1, function(_){
                                        player.canMove=true;
                                        zacharieProgress = 70;
                                    });
                                }
                            }
                            
                            case 70:
                                if(myInventory.findItemByName("Zacharie's Book")!=null){
                                    player.canMove=false;
                                    var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/heresyourcomic')));

                                    var dialogue = new OffDialogue(dialoguee, Bottom);
                                    dialogue.box.alpha = .70;
                                    dialogue.cameras = [camHUD];
                                    add(dialogue);
    
                                    dialogue.finishThing = function(){
                                        new FlxTimer().start(0.1, function(_){
                                            player.canMove=true;
                                            zacharieProgress = 80;

                                            myInventory.addItem('Mysterious Comic', 1, 'You are the main villain in that story', true);

                                            myInventory.removeItem("Zacharie's Book");
                                        });
                                    }
                                }
                                else{
                                    player.canMove=false;

                                    var dialogue = new OffDialogue(['-zacharie-Thank you once again my friend.'], Bottom);
                                    dialogue.box.alpha = .70;
                                    dialogue.cameras = [camHUD];
                                    add(dialogue);
    
                                    dialogue.finishThing = function(){
                                        new FlxTimer().start(0.1, function(_){
                                            player.canMove=true;
    
                                        });
                                    }
                                }
                                case 80:
                                     player.canMove=false;

                                    var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/gogetmymask')));

                                    var dialogue = new OffDialogue(dialoguee, Bottom);
                                    dialogue.box.alpha = .70;
                                    dialogue.cameras = [camHUD];
                                    add(dialogue);
                                    dialogue.finishThing = function(){
                                        new FlxTimer().start(0.1, function(_){
                                            player.canMove=true;
                                            zacharieProgress = 85;
                                        });
                                    }
                                case 85:
                                    if(myInventory.findItemByName("Zacharie's Mask")!=null){
                                        player.canMove=false;

                                        var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/igoturmask')));

                                    var dialogue = new OffDialogue(dialoguee, Bottom);
                                    dialogue.box.alpha = .70;
                                    dialogue.cameras = [camHUD];
                                    add(dialogue);
                                    dialogue.finishThing = function(){
                                        new FlxTimer().start(0.1, function(_){
                                            player.canMove=true;
                                            zacharieProgress = 100;
                                            myInventory.removeItem("Zacharie's Mask");

                                        });
                                    }
                                    }
                                    else{
                                        player.canMove=false;

                                        var dialogue = new OffDialogue(['-zacharie-Thank you once again my friend.'], Bottom);
                                        dialogue.box.alpha = .70;
                                        dialogue.cameras = [camHUD];
                                        add(dialogue);
        
                                        dialogue.finishThing = function(){
                                            new FlxTimer().start(0.1, function(_){
                                                player.canMove=true;
        
                                            });
                                        }
                                    }
                                case 100:
                                    player.canMove=false;

                                var dialogue = new OffDialogue(['-zacharie-Are you ready for a friendly match?.'], Bottom);
                                dialogue.box.alpha = .70;
                                dialogue.cameras = [camHUD];
                                add(dialogue);

                                dialogue.finishThing = function(){
                                    var options = new CoolDecision(['Yes', 'No'], Bottom);
                        
                                    options.box.alpha = .70;
            
                                        options.cameras = [camHUD];
                                        add(options);
                                    
                                        options.finishThing = function(){
                                            switch(options.curSel){
                                                case 0:
                                                    enterBattle(9, 100, 'Zacharie');
                                                case 1:
                                                    new FlxTimer().start(0.1, function(_){
                                                        player.canMove=true;
                                                       
                                                    });
                                            }
                                           
                                        }
                                    
                                }
                            
                        }
                    }
                    if(o.behaviour == Actionable && batterRay(o)){
                        Deciding = true;
                 
                        player.canMove =false;

                        var options = new CoolDecision(['Press it', 'Exit'], Bottom);
                        
                        options.box.alpha = .70;

                            options.cameras = [camHUD];
                            add(options);
                            options.finishThing = function(){
                                if(options.curSel==0){
                                    FlxG.sound.play(Paths.sound('bump2', 'preload'));

                                    o.isPressed = !o.isPressed;
                                    curCode += ${o.ID};
                                    if(curCode.length>7){
                                        FlxG.sound.play(Paths.sound('failure2', 'preload'));

                                        curCode= '';
                                        trace('resetted code cuz u stopid');
                                        for(o in collidableObjects){
                                             
                                           if(o.behaviour == Actionable){
                                            o.isPressed = false;
                                        }

                                        }
                                    }
                                    else if(curCode == '4617290'){
                                        FlxG.sound.play(Paths.sound('puzzleunlocks', 'preload'));

                                        currentProgress = 20;
                                        for(o in collidableObjects){
                                            
                                           if(o.behaviour == Static){
                                            trace('static ID ${o.ID}');
                                            collidableObjects.remove(o);
                                           }

                                    }
                                    }
                                    
                                }
                                player.canMove =true;
                                new FlxTimer().start(0.7, function(_){
                                    Deciding = false;

                                });

                            }
                    }
                        

                  
                    
                    case 'level1-puzzlesneak': 
                        trace('read code dude');
                        player.canMove=false;
                        Deciding = true;

                        var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/smartbatter')));
                        var dialogue = new OffDialogue(dialoguee, Bottom);
                        dialogue.box.alpha = .70;
                        dialogue.cameras = [camHUD];
                        add(dialogue);
                        player.canMove=false;

                        dialogue.finishThing = function(){
                            player.canMove =true;
                            new FlxTimer().start(0.7, function(_){
                                Deciding = false;

                            });
                        }
                 
                    case 'level1':
                     
                    if(o.behaviour == Chest&& o.curAnim!='open'){
    
                        o.animation.play('open');
                        player.canMove = false;
                       var dialogue = new OffDialogue(["-narrator-A lucky ticket has been found."], Upper, true);
                       dialogue.box.alpha = .70;

                       dialogue.cameras = [camHUD];
                       add(dialogue);
                       dialogue.finishThing = function(){
                        myInventory.addItem('Lucky ticket', 2, 'Restores a moderate amount of health');
         


                           player.canMove = true;
                           openedChest.push(o.ID);

                       }
                   }
                        switch(currentProgress){
                            case 100:
                                if(o.ID == 151){
                                    player.canMove = false;
                                    var options = new CoolDecision(['Yes', 'No'], Bottom, 'Would you like to replay Judgement?');
                              
                                      options.box.alpha = .70;
                                      options.cameras = [camHUD];
          
                                      add(options);
                                      options.finishThing = function(){
                                          switch(options.curSel){
                                              case 0:
                                                  enterBattle(0, 100, 'Judge');
                                                  //                                            enterBattle(0,15, 'Judge');
      
                                              case 1:
      
                                          }
                                          new FlxTimer().start(0.1, function(_){
                                              player.canMove = true;
      
                                          });
                                      }
                                }
                            case 15:
                                if(o.ID == 777)
                                    {
                                player.canMove =false;

                                var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/afterjudgement')));
                                var dialogue = new OffDialogue(dialoguee);
                                dialogue.cameras = [camHUD];
                                dialogue.box.alpha = .70;

                                add(dialogue);
                                dialogue.finishThing = function(){
                                    sittingJudge.animation.play('up');
                                    sittingJudge.path = new FlxPath().start([new FlxPoint(0, sittingJudge.y - 700)], 600, FORWARD);
                                    sittingJudge.path.axes = Y;
                                    sittingJudge.path.onComplete = function(_){
                                        collidableObjects.remove(sittingJudge);
                                        player.canMove =true;
                                        currentProgress = 17;
                                    }
                                }
                                    
                            }
                                   
                            case 10:
                                if(o.ID == 777)
                                    {
                                player.canMove =false;

                        trace('i wanna talk judge :c');
                        var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/judegstairs')));
                        var dialogue = new OffDialogue(dialoguee);
                        dialogue.box.alpha = .70;

                        dialogue.cameras = [camHUD];
                        add(dialogue);
                        dialogue.finishThing = function(){
                            var options = new CoolDecision(['Accept', 'Decline']);
                            options.box.alpha = .70;

                            options.cameras = [camHUD];
                            add(options);
                           
                            options.finishThing = function(){
                                switch(options.curSel){
                                    case 0:
                                        trace('and now we switch to ps');
                                        new FlxTimer().start(0.5, function(_){
                                            enterBattle(0,15, 'Judge');
                                        });
                                            
                                        
                                       
                                        


                                    case 1:
                                        var dialogue = new OffDialogue(['-judge-As you wish.']);
                                        dialogue.box.alpha = .70;

                                        dialogue.cameras = [camHUD];
                                        add(dialogue);
                                        dialogue.finishThing = function(){
                                            sittingJudge.animation.play('up');
                                            sittingJudge.path = new FlxPath().start([new FlxPoint(0, sittingJudge.y - 700)], 600, FORWARD);
                                            sittingJudge.path.axes = Y;
                                            sittingJudge.path.onComplete = function(_){
                                                collidableObjects.remove(sittingJudge, true);
                                                player.canMove =true;
                                                currentProgress = 17;
                                            }
                                           

                                        }
                                 }
                             }
                           }
                         }
                    }
                        
                        
                    
                }
           
                //basically collisions that the player can interact with, but not walk throught

        }
        
        for(o in triggerObjects){
            if(o.overlaps(player) && curMap == 'level5enochchase'&& o.ID == 222){
                //enochChase.path.cancel();
                persistentUpdate = false;
                persistentDraw = false;
                FlxG.sound.music.stop();
                openSubState(new OffGameOverSubstate('overworld'));

                trace('batter dided');
            }
           if(player.overlaps(o)){
                switch(curMap){
                    case 'level2-traindamien':

                    if(o.ID == 1001 && FlxG.keys.justPressed.ENTER && !Deciding && player.canMove){
                        player.canMove = false;

                        var ss = new OffDialogue(['-narrator-Please select your destination...'], Upper, true);
                        ss.cameras = [camHUD];
                        ss.box.alpha = .70;

                        add(ss);
                        ss.finishThing = function(){
                            Deciding = true;
                            var options = new CoolDecision(['Elsen', 'Cancel'], Upper);
                        
                            options.box.alpha = .70;
                            options.cameras = [camHUD];
    
                            add(options);
                            options.finishThing=function(){
                                switch(options.curSel){
                                    case 0:
                                        trainTransition('level2-trainelsen', 10000, 'left');

                                    case 1:
    
                                    player.canMove = true;

                                }
    
                                new FlxTimer().start(0.7, function(_){
                                    Deciding = false;
    
                                });
                            }
                        }
                       
                    }
                    case 'level2-trainelsen':

                    if(o.ID == 1001 && FlxG.keys.justPressed.ENTER && !Deciding && player.canMove){

                        player.canMove = false;

                        var ss = new OffDialogue(['-narrator-Please select your destination...'], Upper, true);
                        ss.cameras = [camHUD];
                        ss.box.alpha = .70;

                        add(ss);
                        ss.finishThing = function(){
                            Deciding = true;
                            var options = new CoolDecision(['Damien', 'Cancel'], Upper);
                        
                            options.box.alpha = .70;
                            options.cameras = [camHUD];
    
                            add(options);
                            options.finishThing=function(){
                              

                                switch(options.curSel){
                                    case 0:
                                        trainTransition('level2-traindamien', 9000, 'right');

                                    case 1:
    
                                    player.canMove = true;

                                }
    
                                new FlxTimer().start(0.7, function(_){
                                    Deciding = false;
    
                                });
                            }
                        }
                       
                    }
                    case 'nothing':
                       
                       
                        if(zoneText.text!='zone ${o.ID}' && o.ID<4){
                           
                                zoneText.text = 'zone ${o.ID}';
                                zoneText.color = 0xFFFFFFFF;
                                zoneText.x = 1136;
                                trace('daZon');

                         
                        }
                        else if(o.ID==4 && zoneText.text!='the room')
                                {
                                    zoneText.text = 'the room';
                                    zoneText.color = FlxColor.RED;
                                    zoneText.x = 1136-30;

                                    trace('daRoom');
                                }
                             
                    
                        
                       

                        if(FlxG.keys.justPressed.ENTER && !Deciding){
                            switch(o.ID){

                                case 0:
                                    trace('zone 0');
                                    Deciding = true;
                                    player.canMove = false;
                                    var options = new CoolDecision(['Yes', 'No'], Bottom, 'Enter zone 0?');
                                
                                    options.box.alpha = .70;
                                    options.cameras = [camHUD];

                                    add(options);
                                    options.finishThing=function(){
                                        switch(options.curSel){
                                            case 0:
                                                teleport('level1', 6000, true);
                                            case 1:
                                                player.canMove = true;

                                        }

                                        new FlxTimer().start(0.7, function(_){
                                            Deciding = false;
        
                                        });
                                    }
                                case 1:
                                    trace('zone 1');
                                    Deciding = true;
                                    player.canMove = false;
                                    var options = new CoolDecision(['Yes', 'No'], Bottom, 'Enter zone 1?');
                                
                                    options.box.alpha = .70;
                                    options.cameras = [camHUD];

                                    add(options);
                                    options.finishThing=function(){
                                        switch(options.curSel){
                                            case 0:
                                                teleport('level2-teleport', 7000, true);
                                            case 1:
                                                player.canMove = true;

                                        }

                                        new FlxTimer().start(0.7, function(_){
                                            Deciding = false;
        
                                        });
                                    }
                                case 2:

                                    trace('zone 2');


                                    if(currentProgress>=45 && OffMenuState.currentYear!=2008){
                                        Deciding = true;
                                        player.canMove = false;
                                        var options = new CoolDecision(['Yes', 'No'], Bottom, 'Enter zone 2?');
                                    
                                        options.box.alpha = .70;
                                        options.cameras = [camHUD];
    
                                        add(options);
                                        options.finishThing=function(){
                                            switch(options.curSel){
                                                case 0:
                                                        teleport('level4japhetzone',12222, true);
                                                case 1:
                                                    player.canMove = true;
    
                                            }
    
                                            new FlxTimer().start(0.7, function(_){
                                                Deciding = false;
            
                                            });
                                        }
                                    }
                                    

                                case 3:
                                    trace('zone 3');
                                    if(currentProgress>=50 && OffMenuState.currentYear!=2008){
                                        Deciding = true;
                                        player.canMove = false;
                                        var options = new CoolDecision(['Yes', 'No'], Bottom, 'Enter zone 3?');
                                    
                                        options.box.alpha = .70;
                                        options.cameras = [camHUD];
    
                                        add(options);
                                        options.finishThing=function(){
                                            switch(options.curSel){
                                                case 0:
                                                    teleport('level5enochzone',13333, true);

                                                case 1:
                                                    player.canMove = true;
    
                                            }
    
                                            new FlxTimer().start(0.7, function(_){
                                                Deciding = false;
            
                                            });
                                        }
                                    }


                                case 4:
                                    //75
                                    trace('room');
                                    if(currentProgress>=75 && OffMenuState.currentYear!=2008){
                                        Deciding = true;
                                        player.canMove = false;
                                        var options = new CoolDecision(['Yes', 'No'], Bottom, 'Enter the room?');
                                    
                                        options.box.alpha = .70;
                                        options.cameras = [camHUD];
    
                                        add(options);
                                        options.finishThing=function(){
                                            switch(options.curSel){
                                                case 0:
                                                    if(currentProgress<100)
                                                        teleport('theroom',16666, true);
                                                        else if(currentProgress>=100)
                                                            teleport('theroomPurified',16666, true);

                                                case 1:
                                                    player.canMove = true;
    
                                            }
    
                                            new FlxTimer().start(0.7, function(_){
                                                Deciding = false;
            
                                            });
                                        }
                                    }
                            }
                        }
                        case 'purifiedhallway':
                            if(o.ID ==190){
                                for(o in triggerObjects){
                                    if(o.ID==190){
                                        triggerObjects.remove(o);

                                    }
                                }
                                startLastJudgeBatterCutscene();

                            }
                        case 'level6queenzone':
                            if(o.ID == 129){
                                for(o in triggerObjects){
                                    if(o.ID==129){
                                        triggerObjects.remove(o);

                                    }
                                }
                                startQueenCutscene();
                            }
                    case 'level6hallway':
                        switch(currentProgress){
                            case 57:
                                if(o.ID ==123){
                                    for(o in triggerObjects){
                                        if(o.ID==123){
                                            triggerObjects.remove(o);

                                        }
                                    }

                                    player.canMove = false;
                                    var dialogue = new OffDialogue(['-queen-Why are you doing this?']);
                                    dialogue.box.alpha = .70;
                        
                                    dialogue.cameras = [camHUD];
                                    dialogue.finishThing = function(){
                                        player.canMove= true;
                        
                        
                                    }
                                    add(dialogue);

                                    currentProgress = 59;
                                }
                        }
                    
                    case 'level3mines':
                        switch(currentProgress){
                            case 30:
                                if(o.ID == 22){
                                 

                                    triggerObjects.remove(o);
                                    startGhostCutscene();
                                    currentProgress = 35;

                                }
                        }
                    case 'level1-unlockedzone':
                        switch(currentProgress){
                            case 20:

                                trace('trigger cutscene');
                                for(o in triggerObjects){
                                    if(o.ID == 100){

                                        triggerObjects.remove(o);
                                        trace('removed trigger lol');

                                    }
                                }
                                currentProgress = 25;

                               
                                startCutScene();

                             
    
                            
                        }
                        case 'level4japhetzone':
                            switch(currentProgress){
                                case 40:
                                    for(o in triggerObjects){
                                        if(o.ID == 777){

                                            triggerObjects.remove(o);
                                            trace('removed trigger lol');

                                        }
                                    }
                                    startJaphetCutscene();
                            }
                    case 'level1':
                            switch(currentProgress){
                                case 0:

                                    trace('trigger intro');
                                    for(o in triggerObjects){
                                        if(o.ID == 1){

                                            triggerObjects.remove(o);
                                            trace('removed trigger lol');

                                        }
                                    }
                                    currentProgress = 10;
                                    collidableObjects.destroy();
                               
                                    collidableObjects = new FlxTypedGroup<Dynamic>();
                                    

                                    player.canMove = true;

                                 

                                    add(collidableObjects);
                                    loadMapObjects();

                                   
                                    startIntro();

                                    
                                  
                                
                            }
                         
                }
            }
          
          
            //basically objects that if the player steps will make something happen
        }
    }
    
    public static var removedItems:Array<Int>=[];
    var inCutscene:Bool = false;
    public  static var currentProgress:Int = 0;
    function teleport(nextMap:String, nextSpawn:Int, ?teleportAnim:Bool = false, ?shouldMove:Bool = false){

        if(!teleportAnim){
            player.canMove = false;
            collidableObjects.remove(player);

            remove(collidableObjects);
            remove(triggerObjects);
    
            remove(ray);
            curSpawn = nextSpawn;
    
            trace('i wanna get in');
        
            switchMap(nextMap, shouldMove);
            add(collidableObjects);
            add(triggerObjects);
            collidableObjects.add(player);

            add(ray);
            add(level.aboveLayer);
        }
        else{
            player.canMove = false;

            player.visible=false;
            var coolteleport = new FlxSprite(player.x-35,player.y-103);
            coolteleport.frames = Paths.getSparrowAtlas('rpgshit/teleport');
            coolteleport.animation.addByPrefix('teleport', 'teleport teleporting', 24, false);
            coolteleport.animation.play('teleport');
            add(coolteleport);
            FlxG.sound.play(Paths.sound('night', 'preload'));

            coolteleport.animation.finishCallback=function(_){
                justTeleported=true;
                collidableObjects.remove(player);

                remove(collidableObjects);
                remove(triggerObjects);
        
                remove(ray);

                curSpawn = nextSpawn;
        
                trace('i wanna get in');
            
                switchMap(nextMap, false);
                add(collidableObjects);
                add(triggerObjects);
                collidableObjects.add(player);
              
   
                add(ray);
                add(level.aboveLayer);

                coolteleport.destroy();

            }
        }
      


        //coolteleport.setPosition(player.x+numimi.x,player.y+numimi.y);
        //-35,-103
    }
    public var justTeleported:Bool = false;
    function checkOpenedChest(chest:CoolBox){
        if(elSave!=null){

            var deta = elSave;
            openedChest = deta.openedChest;
            trace('we loaded the opened chest from the save');

             
           
        }

        if(openedChest.contains(chest.ID)){
                chest.animation.play('open');
                 trace('this fuken chest is open');

            }
            else
                trace('openedChest doesnt have chest ${chest.ID} opened');

       
      
    }
    public static var openedChest:Array<Int>=[];
    function startCutScene(){


        player.canMove= false;
        var p = new FlxPath([new FlxPoint(765,990)]);

        var npc = new DaNpc(765,1216, 'Judge',p);
        npc.immovable = true;
        collidableObjects.add(npc);
        npc.path.start(null, npc.SPEED);
        npc.path.autoCenter=false;

        npc.path.axes = Y;
        npc.path.onComplete = (_)->{
            trace('we reached the place');
            npc.path.cancel();

            var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/redBoxExplanation')));
            var dialogue = new OffDialogue(dialoguee);
            dialogue.box.alpha = .70;

            dialogue.cameras = [camHUD];
            dialogue.finishThing = function(){
                player.canMove= true;


            }
            add(dialogue);
            

        }

    }
    public function startIntro(){

        camFocus = 'none';
        player.canMove= false;

        FlxTween.tween(camFollow, {y:npc.getGraphicMidpoint().y}, 3, {onComplete:function(_){

            camFocus = 'npc';
            
            npc.path.start(null, npc.SPEED);
            npc.path.axes =Y;

            npc.path.onComplete = (_)->{
                trace('we reached the place');
                npc.path.cancel();

                var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/intro')));
                var dialogue = new OffDialogue(dialoguee);
                dialogue.box.alpha = .70;

                dialogue.cameras = [camHUD];
                dialogue.finishThing = function(){
                    camFocus = 'player';

                    //var newPoint:Array<FlxPoint> = [new FlxPoint(npc.x, 677)];

                    //npc.path = new FlxPath(newPoint);

                    npc.path.axes = Y;

                    npc.path.start(null, npc.SPEED - 20, BACKWARD);
                    npc.path.onComplete = (_) -> {

                        player.canMove = true;

                        npc.path.cancel();
                        remove(npc);

                    }

                }
                add(dialogue);
                
                //player.canMove= true;
    
            }

        }});
       
       
      
    }
    //var obj = new ObjectController(npc,1);
    //add(obj);
    override function destroy(){

		super.destroy();
	}
    var bars:FlxSprite;

    function triggerDetection(){
        if(triggersMap.get(curMap)!=null)
        for(trigger in triggersMap.get(curMap)){
            if (FlxG.overlap(player, trigger))
                {
                   if(player.canMove){
                       player.canMove = false;
                       collidableObjects.remove(player);
                       remove(ray);
                       curSpawn = trigger.nextSpawn;

                       trace('i wanna get in');
                    
                       switchMap(trigger.warpsTo);
                       collidableObjects.add(player);
                       add(ray);
                       break;
                   }
        
                }
        }
        
        /*
        switch(curMap){
            case 'level1':
                if (FlxG.overlap(player, roomPuzzle))
                    {
                       if(player.canMove){
                           player.canMove = false;
                           curSpawn = 1;

                           trace('i wanna get in');
                        
                           switchMap('level1-puzzlesneak');
                           
                       }
            
                    }
                    case 'level1-puzzlesneak':
                        if (FlxG.overlap(player, mainRoom))
                            {
                               if(player.canMove){
                                   player.canMove = false;
                                   curSpawn = 2;
                                   trace('i wanna get in');
                                
                                   switchMap('level1');
                                   
                               }
                    
                            }
        
                        }   
                        */
                     }
        
}
/*  if(o.behaviour == Chest&& o.curAnim!='open'){
    
                                     o.animation.play('open');
                                     player.canMove = false;
                                    var dialogue = new OffDialogue(["-batter-It's empty."], Upper, true);
                                    dialogue.box.alpha = .70;
    
                                    dialogue.cameras = [camHUD];
                                    add(dialogue);
                                    dialogue.finishThing = function(){
                                        player.canMove = true;
    
                                    }
                                }
                                */