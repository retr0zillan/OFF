package;

import flixel.FlxSprite;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import states.*;
class BattleStatus extends FlxSpriteGroup{
    public var somanyboxes:FlxSprite;
    var infoText:FlxText;
    //120/  120
    var Bv:Array<String>=['The Batter', 'Pure', 'HP', 'healf'];
    var positions:Array<FlxPoint>=[
        new FlxPoint(226,677),
        new FlxPoint(517,677),
        new FlxPoint(790,677),
        new FlxPoint(841,677)


    ];
    var iDD:Array<FlxText>=[];
    public function new(x:Float, y:Float, ?character:String = 'Batter'){
        super(x,y);
        this.character = character;
        somanyboxes = new FlxSprite(0,0).loadGraphic(Paths.image('battleHealth/battleStatus', 'preload'));
        add(somanyboxes);

        for(i in 0...4){
            infoText = new FlxText(positions[i].x, 675, 0, Bv[i], 24);
            infoText.font = 'assets/fonts/Minecraftia-Regular.ttf';
            switch(i){
                case 1:
                    infoText.text = PlayState.daIns.purificationState;
                case 0:
                    if(character == 'Batter')
                        infoText.text = 'The Batter';
                    else if(character == 'PlayableJudge')
                        infoText.text = 'The Judge';

                case 2:
                    infoText.color = 0xFFf6af29;

                case 3:
                    
                    infoText.text = '${MapTestState.curHealth}/  ${MapTestState.maxHealth}';
          

            }
        
            add(infoText);
            iDD.push(infoText);
        }
    }
    function keepShitUpdated(){

    }
    var character:String = 'Batter';
    override function update(elapsed:Float){
        super.update(elapsed);
        //iDD[3].text = '${MapTestState.curHealth}/  ${MapTestState.maxHealth}';

            iDD[1].text = PlayState.daIns.purificationState;

            iDD[3].text = '${MapTestState.curHealth}/  ${MapTestState.maxHealth}';
      


    }
}