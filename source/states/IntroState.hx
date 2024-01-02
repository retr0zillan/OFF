package states;
#if desktop
import Discord.DiscordClient;
#end
import Shaders;

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

class IntroState extends MusicBeatState{
    var yournameis:CoolDecision;
    var blackBars:FlxSprite;
    var batter:DaPlayer;
    public static var playerSex:String = 'Male';
    var offText:FlxText;
    var offText2:FlxText;

    override function create(){
        super.create();


        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(bg);
     
         batter = new DaPlayer(613,228);
         batter.canMove = false;
        batter.scale.set(4,4);
        batter.visible = false;
        add(batter);
        
        offText = new FlxText(471,179,0,'', 228);
        offText.text = 'OFF';
        offText.font = 'assets/fonts/offgamefont.otf';
        offText.alpha =0;

        offText2 = new FlxText(346,339,0,'', 153);
        offText2.text = 'Judgement';
        offText2.font = 'assets/fonts/offgamefont.otf';
        offText2.alpha =0;
        add(offText);

        //var obj = new ObjectController(offText2,1);
        //add(obj);
    yournameis = new CoolDecision(['Yes','No'], Bottom, 'Your name is ${NameSelectionState.completeName}, correct?');
    add(yournameis);
    yournameis.finishThing = function(){
        switch(yournameis.curSel){
            case 0:
                trace('oky doky');
               var sex = new CoolDecision(["I'm a boy","I'm a girl"], Bottom);
                add(sex);
                sex.finishThing = function(){
                    switch(sex.curSel){
                        case 0:
                            playerSex = 'Male';
                        case 1:
                            playerSex = 'Female';

                    }
                    var dialoguee = CoolUtil.coolTextFile2(File.getContent(Paths.txt('dialogue/postNameIntro')));

                    var postDia = new OffDialogue(dialoguee, Bottom, true);
                    add(postDia);
                    postDia.appearBatter = function(){
                        batter.visible = true;
                    }
                    postDia.finishThing=function(){
                        batter.visible = false;

                        new FlxTimer().start(1, function(_){
                            FlxG.sound.play(Paths.sound('trimmed', 'preload'));

                            FlxTween.tween(offText, {alpha:1}, 9, {onComplete:function(_){
                                
                                    FlxTween.tween(offText, {alpha:0}, 5, {onComplete:function(_){
                                        FlxG.switchState(new MapTestState());
                                    }});

                                
                            }});


                        });
                        trace('and now the cool transition lmao');
                    }
                }
            case 1:
                NameSelectionState.completeName = '';
                FlxG.switchState(new NameSelectionState());
        }
    }











        
        blackBars = new FlxSprite().loadGraphic(Paths.image('BlackBars1280', 'preload'));
        add(blackBars);
        
    }
   
    override function update(elapsed:Float){
        super.update(elapsed);
        //scaleObject(batter);
        //sizeText(offText2);
    }
    var scaler:Float = 1;

    var sizer:Int = 228;
    function sizeText(text:FlxText){
        FlxG.watch.addQuick('sizer', sizer);
        

        if(FlxG.keys.pressed.E){
            sizer +=1;
        }
        if(FlxG.keys.pressed.Q){
            sizer  -= 1;

        }
        text.size = sizer;
    }
    function scaleObject(object:FlxSprite){
        FlxG.watch.addQuick('scaler', scaler);
        

        if(FlxG.keys.pressed.E){
            scaler += 0.1;
        }
        if(FlxG.keys.pressed.Q){
            scaler  -= 0.1;

        }
        object.setGraphicSize(Std.int(object.frameWidth*scaler));
    }
}