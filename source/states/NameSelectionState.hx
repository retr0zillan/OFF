package states;

#if desktop
import Discord.DiscordClient;
#end
import Shaders;
import Options;

import flixel.system.FlxAssets.FlxShader;
import openfl.filters.ShaderFilter;
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
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.group.*;
import flixel.math.FlxVelocity;
import EngineData.WeekData;
import CoolBox.Behaviour;
import openfl.ui.Keyboard;
class NameSelectionState extends MusicBeatState{
    var bg:FlxSprite;
    var blackBars:FlxSprite;
    var nameContainer:FlxSprite;
    var letter:FlxText;
    var container:Array<FlxText>=[];
    var pointer:FlxSprite;
    var num:FlxPoint = new FlxPoint();

    var inDia:Bool = false;
    public static var completeName:String='';
    var elSave = OffSaveGame.loadData();

    function selectHelper(){
        #if debug
        FlxG.watch.addQuick('num', '${num.x}x ${num.y}y');
        pointer.setPosition(container[prevChar].x + num.x, container[prevChar].y+ num.y);
        if(FlxG.keys.pressed.LEFT){
            num.x -=1;
        }
        if(FlxG.keys.pressed.RIGHT){
            num.x +=1;
    
        }
        if(FlxG.keys.pressed.UP){
            num.y -=1;
    
        }
        if(FlxG.keys.pressed.DOWN){
            num.y +=1;
    
        }
        //scalePortrait();
        #end
       }
    override function create(){
        super.create();
        DiscordClient.changePresence("Introduction", null, null, true);

        completeName = '';
        MapTestState.currentProgress=0;
        MapTestState.openedChest = [];
        MapTestState.myInventory = new PlayerInventory();
        MapTestState.curHealth = 120;
        MapTestState.maxHealth = 120;
        MapTestState.playerLevel = 1;
        MapTestState.elsenInteractions = 0;
        MapTestState.skin = 'BatterRPG';
        MapTestState.zacharieProgress = 0;
        MapTestState.cowPets = 0;
        MapTestState.fattyDeaths = 0;
        if(elSave!=null){
            OffSaveGame.eraseData();

            
        }
        FlxG.sound.music.stop();
        bg = new FlxSprite().loadGraphic(Paths.image('name/nameBg', 'preload'));
        add(bg);

        nameContainer = new FlxSprite().loadGraphic(Paths.image('name/nameContainer', 'preload'));
        add(nameContainer);
        
        pointer = new FlxSprite().loadGraphic(Paths.image('name/namePointer', 'preload'));
        add(pointer);

        for(i in 0...14){
            letter = new FlxText(354+(i*40), 625, 0, '', 32);
            letter.font = 'assets/fonts/minecraftiaItalic.otf';
            letter.antialiasing = false;
            letter.italic = true;
            add(letter);
            container.push(letter);
        }
       
        pointer.setPosition(container[prevChar].x + -8, container[prevChar].y);

        blackBars = new FlxSprite().loadGraphic(Paths.image('BlackBars1280', 'preload'));
        add(blackBars);
        
     
    }
    var curChar:Int = 0;
    var whiteList = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 
    'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A',
     'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 
     'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];








     var prevChar:Int=0;
     var fukenCaps:Bool=false;
   
     var conversionMap:Map<String, Int>=[
        'zero'=>0,
        'one'=>1,
        'two'=>2,
        'three'=>3,
        'four'=>4,
        'five'=>5,
        'six'=>6,
        'seven'=>7,
        'eight'=>8,
        'nine'=>9,
     ];
     function nameEasterEgg(){


        var nombreEncontrado:Bool = false;
        
        for (name in names)
        {
            if (completeName.toLowerCase() == name)
            {
                nombreEncontrado=true;
                inDia=true;
                trace('found ' +name);
                switch(name){
                    case 'batter':
                        var dialogue = new OffDialogue(['-batter-No.'], Upper);
                        add(dialogue);
                        dialogue.finishThing = function(){
                            new FlxTimer().start(0.3, function(_){
                                inDia = false;

                            });
                        }

                    case 'judge':
                        var dialogue = new OffDialogue(["-judge-Ah, a bold choice indeed. However, that name you seek to claim... It already resonates with my essence."], Upper);
                        add(dialogue);
                        dialogue.finishThing = function(){
                            new FlxTimer().start(0.3, function(_){
                                inDia = false;

                            });
                        }
                    case 'dedan':
                        var dialogue = new OffDialogue(['-dedan- Well, well, well, look whos trying to steal my name! Aint that a pathetic attempt? Listen up, you sorry excuse for an imposter, that name is mine.'], Upper);
                        add(dialogue);
                        dialogue.finishThing = function(){
                            new FlxTimer().start(0.3, function(_){
                                inDia = false;

                            });
                        }
                    case 'elsen':
                        var dialogue = new OffDialogue(['-elsen-Umm... Excuse me, umm... Im sorry, but... that name... umm... its... umm... taken by... umm... me, you know?.'], Upper);
                        add(dialogue);
                        dialogue.finishThing = function(){
                            new FlxTimer().start(0.3, function(_){
                                inDia = false;

                            });
                        }
                    case 'Enoch':
                        var dialogue = new OffDialogue(["-enoch-Oh, I see you're attempting to borrow my name, huh? Well, I hate to break it to you, but that name carries the weight of authority and accomplishment.."], Upper);
                        add(dialogue);
                        dialogue.finishThing = function(){
                            new FlxTimer().start(0.3, function(_){
                                inDia = false;

                            });
                        }
                    case 'japhet':
                        var dialogue = new OffDialogue(["-japhet-Ah, attempting to claim my name, are you? How quaint. But let me remind you, insignificant mortal, that name is mine."], Upper);
                        add(dialogue);
                        dialogue.finishThing = function(){
                            new FlxTimer().start(0.3, function(_){
                                inDia = false;

                            });
                        }
                    case 'zacharie':
                        var dialogue = new OffDialogue(["-zacharie-Well, well, well, what have we here? Seems like someone wants to borrow my name, huh? Not a bad choice, my friend."], Upper);
                        add(dialogue);
                        dialogue.finishThing = function(){
                            new FlxTimer().start(0.3, function(_){
                                inDia = false;

                            });
                        }
                    case 'queen':
                        var dialogue = new OffDialogue(["-queen-That name is mine alone."], Upper);
                        add(dialogue);
                        dialogue.finishThing = function(){
                            new FlxTimer().start(0.3, function(_){
                                inDia = false;

                            });
                        }
                    case 'hugo':
                        var dialogue = new OffDialogue(["-hugo-Sorry, but that name is mine."], Upper);
                        add(dialogue);
                        dialogue.finishThing = function(){
                            new FlxTimer().start(0.3, function(_){
                                inDia = false;

                            });
                        }
                }
                break;
            }
        }
      
            if(!nombreEncontrado)
            {
                FlxG.switchState(new IntroState());

                trace("El nombre no fue encontrado en la cadena.");
            }

     }
     var names:Array<String> = ["judge", "dedan", "elsen", "hugo", "enoch", "japhet", "zacharie", "queen", "batter"];

     var easterName:String;
    override function update(elapsed:Float){
        FlxG.watch.addQuick('curChar', curChar);
        FlxG.watch.addQuick('prevChar', prevChar);
        FlxG.watch.addQuick('name', completeName);


        //selectHelper();

        if(controls.ACCEPT && completeName!= '' && !inDia){
            nameEasterEgg();
        }
        if(FlxG.keys.justPressed.CAPSLOCK){
            fukenCaps=!fukenCaps;
        }
        if (FlxG.keys.firstJustPressed() != -1) {
            if(curChar<container.length)
                {
                    var daK:FlxKey = FlxG.keys.firstJustPressed();
                    var strKey:String;
                
                    // Verificar si se presionó la tecla Shift o si se activó el bloqueo de mayúsculas
                    if (FlxG.keys.pressed.SHIFT || fukenCaps) {
                        // Obtener el carácter en mayúscula
                       strKey =  daK.toString().toUpperCase();
                    } else {
                        // Obtener el carácter en minúscula
                        strKey =  daK.toString().toLowerCase();
                    }
                    if(conversionMap.exists(strKey)){
                        strKey = '${conversionMap.get(strKey)}';
                    }
                   
                    trace(strKey);
                    if (whiteList.contains(strKey)) {
                        trace('whiteList contains that character');
                        FlxG.sound.play(Paths.sound('Chariot1', 'preload'));
                
                        container[curChar].text = strKey;
                        prevChar = curChar;
                        curChar++;
                        pointer.setPosition(container[prevChar].x + -8, container[prevChar].y);
                        completeName += strKey;

                    }
                }
            
        }
        if(controls.BACK){
            
            if(curChar>0){
                FlxG.sound.play(Paths.sound('Chariot2', 'preload'));

                container[prevChar].text = '';
                completeName = completeName.substr(0, prevChar) + completeName.substr(prevChar + 1);

                curChar=prevChar;
                prevChar--;

                    if(prevChar>=0)
                pointer.setPosition(container[prevChar].x + -8, container[prevChar].y);

            }
          


        }
      
        super.update(elapsed);
    }
}