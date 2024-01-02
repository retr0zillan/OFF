package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.FlxObject;
import flixel.FlxBasic;
import states.*;
import Options;
import Shaders;

class Stage extends FlxTypedGroup<FlxBasic> {
  public var objectID:Map<String,
  FlxSprite> = [];
  
  public var foreGroundObjID:Map<String,
  FlxSprite> = [];
  public static var songStageMap:Map<String,String> = [

    "tutorial"=>"stage",
    "Spectral-Curveball"=>"yellow",

  ];

  public var hasMultipleCharacters:Bool = false;
  public static var stageNames:Array<String> = [
    "stage",
    "yellow",
    "purple",
    "red",
    "pink",
    "green",
    "black",
    "white"
  ];

  public var doDistractions:Bool = true;

  // spooky bg
  public var halloweenBG:FlxSprite;
  var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;


  // philly bg
  public var lightFadeShader:BuildingEffect;
  public var phillyCityLights:FlxTypedGroup<FlxSprite>;
  public var phillyTrain:FlxSprite;
  public var trainSound:FlxSound;
  public var curLight:Int = 0;

  public var trainMoving:Bool = false;
	public var trainFrameTiming:Float = 0;

	public var trainCars:Int = 8;
	public var trainFinishing:Bool = false;
	public var trainCooldown:Int = 0;

  // limo bg
  public var fastCar:FlxSprite;
  public var limo:FlxSprite;
  var fastCarCanDrive:Bool=true;

  // misc, general bg stuff

  public var bfPosition:FlxPoint = FlxPoint.get(770,450);
  public var dadPosition:FlxPoint = FlxPoint.get(100,100);
  public var gfPosition:FlxPoint = FlxPoint.get(400,130);
  public var camPos:FlxPoint = FlxPoint.get(100,100);
  public var camOffset:FlxPoint = FlxPoint.get(100,100);

  public var layers:Map<String,FlxTypedGroup<FlxBasic>> = [
    "boyfriend"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of all characters, but below the foreground
    "dad"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the dad and gf but below boyfriend and foreground
    "gf"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the gf but below the other characters and foreground
  ];
  public var foreground:FlxTypedGroup<FlxBasic> = new FlxTypedGroup<FlxBasic>(); // stuff layered above every other layer
  public var overlay:FlxSpriteGroup = new FlxSpriteGroup(); // stuff that goes into the HUD camera. Layered before UI elements, still

  public var boppers:Array<Array<Dynamic>> = []; // should contain [sprite, bopAnimName, whichBeats]
  public var dancers:Array<Dynamic> = []; // Calls the 'dance' function on everything in this array every beat

  public var defaultCamZoom:Float = 1.05;

  public var curStage:String = '';

  // other vars
  public var gfVersion:String = 'gf';
  public var gf:Character;
  public var boyfriend:Character;
  public var dad:Character;
  public var currentOptions:Options;
  public var centerX:Float = -1;
  public var centerY:Float = -1;

  override public function destroy(){
    bfPosition = FlxDestroyUtil.put(bfPosition);
    dadPosition = FlxDestroyUtil.put(dadPosition);
    gfPosition = FlxDestroyUtil.put(gfPosition);
    camOffset =  FlxDestroyUtil.put(camOffset);

    super.destroy();
  }


  public function setPlayerPositions(?p1:Character,?p2:Character,?gf:Character){

    if(p1!=null)p1.setPosition(bfPosition.x,bfPosition.y);
    if(gf!=null)gf.setPosition(gfPosition.x,gfPosition.y);
    if(p2!=null){
      p2.setPosition(dadPosition.x,dadPosition.y);
      camPos.set(p2.getGraphicMidpoint().x, p2.getGraphicMidpoint().y);
    }

    if(p1!=null){
      switch(p1.curCharacter){

      }
    }

    if(p2!=null){

      switch(p2.curCharacter){
        case 'gf':
          if(gf!=null){
            p2.setPosition(gf.x, gf.y);
            gf.visible = false;
          }
        case 'dad':
          camPos.x += 400;
        case 'pico':
          camPos.x += 600;
        case 'senpai' | 'senpai-angry':
          camPos.set(p2.getGraphicMidpoint().x + 300, p2.getGraphicMidpoint().y);
        case 'spirit':
          camPos.set(p2.getGraphicMidpoint().x + 300, p2.getGraphicMidpoint().y);
        case 'bf-pixel':
          camPos.set(p2.getGraphicMidpoint().x, p2.getGraphicMidpoint().y);
      }
    }

    if(p1!=null){
      p1.x += p1.posOffset.x;
      p1.y += p1.posOffset.y;
    }
    if(p2!=null){
      p2.x += p2.posOffset.x;
      p2.y += p2.posOffset.y;
    }


  }

  public function new(stage:String,currentOptions:Options){
    super();
   
    curStage=stage;
    this.currentOptions=currentOptions;

    overlay.scrollFactor.set(0,0); // so the "overlay" layer stays static

    switch (stage){
      case 'philly':
        var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky','week3'));
        bg.scrollFactor.set(0.1, 0.1);
        add(bg);

        var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city','week3'));
        city.scrollFactor.set(0.3, 0.3);
        city.setGraphicSize(Std.int(city.width * 0.85));
        city.updateHitbox();
        add(city);
        lightFadeShader = new BuildingEffect();

        //modchart.addCamEffect(rainShader);

        phillyCityLights = new FlxTypedGroup<FlxSprite>();
        add(phillyCityLights);

        for (i in 0...5)
        {
                var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i,'week3'));
                light.scrollFactor.set(0.3, 0.3);
                light.visible = false;
                light.setGraphicSize(Std.int(light.width * 0.85));
                light.updateHitbox();
                light.antialiasing = true;
                light.shader=lightFadeShader.shader;
                phillyCityLights.add(light);
        }

        var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain','week3'));
        add(streetBehind);

        phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train','week3'));
        add(phillyTrain);

        trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
        FlxG.sound.list.add(trainSound);

        // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

        var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street','week3'));
        add(street);

        centerX = city.getMidpoint().x;
        centerY = city.getMidpoint().y;
      
      case 'blank':

      case 'yellow': 
        defaultCamZoom = 1;
        var yellloW:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('Yellow','week1'));
        yellloW.antialiasing = true;
        yellloW.active = false;
        add(yellloW);
        objectID['yellloW'] = yellloW;

        var overlay:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('Overlay','week1'));
        overlay.antialiasing = true;
        overlay.blend = ADD;

        overlay.active = false;
        foreground.add(overlay);
        foreGroundObjID['overlay'] = overlay;

        centerX = 696;
        centerY = 420;

        case 'purple':
          hasMultipleCharacters = true;

        

          
          defaultCamZoom = 1;
          var yellloW:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('Purple','week2'));
          yellloW.antialiasing = true;
          yellloW.active = false;
          add(yellloW);
          objectID['yellloW'] = yellloW;
  
          var overlay:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('Overlay','week2'));
          overlay.antialiasing = true;
          overlay.active = false;
          overlay.blend = ADD;

          foreground.add(overlay);
          foreGroundObjID['overlay'] = overlay;
  
          for(i in 0...3){
            var ghosty = new Character(100,100, 'Ghost', false);
            ghosty.ID = i;
            if(i==0)
            layers.get('dad').add(ghosty);
            else
              layers.get('gf').add(ghosty);




            objectID['ghosty${i}'] = ghosty;
            PlayState.daIns.opponents.push(ghosty);
          }
    
          centerX = 696;
          centerY = 420;
          case 'red': 
            defaultCamZoom = 1;
            var yellloW:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('Red','week3'));
            yellloW.antialiasing = true;
            yellloW.active = false;
            add(yellloW);
            objectID['yellloW'] = yellloW;
    
            var overlay:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('Overlay','week3'));
            overlay.antialiasing = true;
            overlay.blend = ADD;

            overlay.active = false;
            foreground.add(overlay);
            foreGroundObjID['overlay'] = overlay;
    
            centerX = 696;
            centerY = 420;

            case 'pink': 
              defaultCamZoom = 1;
              var yellloW:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('Pink','week4'));
              yellloW.antialiasing = true;
              yellloW.active = false;
              add(yellloW);
              objectID['yellloW'] = yellloW;
      
              var overlay:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('Overlay','week4'));
              overlay.antialiasing = true;
              overlay.active = false;
              overlay.blend = ADD;

              foreground.add(overlay);
              foreGroundObjID['overlay'] = overlay;
      
              centerX = 696;
              centerY = 420;

              case 'green': 
                defaultCamZoom = 1;
                var yellloW:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('Green','week5'));
                yellloW.antialiasing = true;
                yellloW.active = false;
                add(yellloW);
                objectID['yellloW'] = yellloW;
        
                var overlay:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('Overlay','week5'));
                overlay.antialiasing = true;
                overlay.blend = ADD;

                overlay.active = false;
                foreground.add(overlay);
                foreGroundObjID['overlay'] = overlay;
        
                centerX = 696;
                centerY = 420;
                case 'black': 
                  defaultCamZoom = 1;
                  var yellloW:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('Black','week6'));
                  yellloW.antialiasing = true;
                  yellloW.active = false;
                  add(yellloW);
                  objectID['yellloW'] = yellloW;
          
          
                  centerX = 696;
                  centerY = 420;

                  case 'white': 
                    defaultCamZoom = 1;
                    var yellloW:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('White','week8'));
                    yellloW.antialiasing = true;
                    yellloW.active = false;
                    add(yellloW);
                    objectID['yellloW'] = yellloW;
            
                    var overlay:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('Overlay','week8'));
                    overlay.antialiasing = true;
                    overlay.blend = ADD;
                    overlay.active = false;
                    foreground.add(overlay);
                    foreGroundObjID['overlay'] = overlay;
            
                    centerX = 696;
                    centerY = 420;
      default:
        defaultCamZoom = 1;
        curStage = 'stage';
        var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback','shared'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.9, 0.9);
        bg.active = false;
        add(bg);

        var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront','shared'));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.antialiasing = true;
        stageFront.scrollFactor.set(0.9, 0.9);
        stageFront.active = false;
        add(stageFront);

        var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains','shared'));
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
        stageCurtains.updateHitbox();
        stageCurtains.antialiasing = true;
        stageCurtains.scrollFactor.set(1.3, 1.3);
        stageCurtains.active = false;

        centerX = bg.getMidpoint().x;
        centerY = bg.getMidpoint().y;

        foreground.add(stageCurtains);
      }
  }


  public function beatHit(beat){
    for(b in boppers){
      if(beat%b[2]==0){
        b[0].animation.play(b[1],true);
      }
    }
    for(d in dancers){
      d.dance();
    }

    if(doDistractions){

      switch(curStage){
       
      }
    }
  }

  override function update(elapsed:Float){
    switch(curStage){
   
    }


    super.update(elapsed);
  }

 
  override function add(obj:FlxBasic){
    if(OptionUtils.options.antialiasing==false){
      if((obj is FlxSprite)){
        var sprite:FlxSprite = cast obj;
        sprite.antialiasing=false;
      }else if((obj is FlxTypedGroup)){
        var group:FlxTypedGroup<FlxSprite> = cast obj;
        for(o in group.members){
          if((o is FlxSprite)){
            var sprite:FlxSprite = cast o;
            sprite.antialiasing=false;
          }
        }
      }
    }
    return super.add(obj);
  }

}
