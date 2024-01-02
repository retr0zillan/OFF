package states;

import Controls.Control;
import flixel.FlxG;
import flixel.text.FlxText;

import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ui.*;
using StringTools;
import flixel.math.FlxPoint;

class OffPauseSubState extends MusicBeatSubstate
{
	var startTimer:FlxTimer;
	var grpMenuShit:FlxTypedGroup<Alphabet>;

    var quitLayer:QuitLayer;
	var menuItems:Array<String> = [
		'Objects',
		'Status',
		'Options',
        'Quit'];


	var pauseMusic:FlxSound;
	var countingDown:Bool=false;

    var mainPage:FlxTypedGroup<FlxText>;
    var mainPageSelector:FlxSprite;
    var batterPortrait:FlxSprite;
    var curSel:Int = 0;
    public static var inss:OffPauseSubState;
    var character:String;
	public function new(?curChar:String = 'Batter')
	{
		super();
        this.character = curChar;
        inss = this;
		

		var bg:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('pauseMenu/offMenu', 'preload'));
		bg.scrollFactor.set();
		add(bg);

        mainPageSelector = new FlxSprite().loadGraphic(Paths.image('pauseMenu/selectBarMainPage', 'preload'));
		mainPageSelector.scrollFactor.set();
		add(mainPageSelector);

        batterPortrait = new FlxSprite(483,54).loadGraphic(Paths.image((character=='Batter'?'pauseMenu/batterPort':'pauseMenu/judgePort'), 'preload'));
		batterPortrait.scrollFactor.set();
		add(batterPortrait);

      
        statusSel = new FlxSprite(634,33).loadGraphic(Paths.image('pauseMenu/statsSelPix', 'preload'));
		statusSel.scrollFactor.set();
        statusSel.alpha=0;
		add(statusSel);

        mainPage = new FlxTypedGroup<FlxText>();
        add(mainPage);
       

        bars = new FlxSprite(0,0).loadGraphic(Paths.image('BlackBars1280', 'preload'));
        bars.scrollFactor.set();
        add(bars);

        loadMainpageStuff();

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}
    var bars:FlxSprite;

    var statusSel:FlxSprite;
    public  var curPage:Int=10;
    var objectsLayer:ObjectsLayer;
    var canPlaySound:Bool = true;
    function switchPage(page:Int){
        curPage=page;
        switch(curPage){
            case 1:
                mainPageSelector.alpha=0;

                statusSel.alpha=1;

            case 0:
                objectsLayer = new ObjectsLayer();
                add(objectsLayer);
                canPlaySound=false;
                trace('adding objs layer');
            case 3:
                quitLayer = new QuitLayer();
              
                add(quitLayer);
                trace('adding quit layer');


        }
    }
    function loadMainpageStuff(){
        for(i in 0...menuItems.length){
            var optionText = new FlxText(197, 40 +(i*52), 0, menuItems[i], 29);
            optionText.font = 'assets/fonts/Minecraftia-Regular.ttf';
            optionText.scrollFactor.set();

            if(i == 2){
                optionText.alpha = 0.5; 
            }
            mainPage.add(optionText);

        }
        for(i in 0...2){
            var creditText = new FlxText(creditsPos[i].x, creditsPos[i].y, 0, credits[i], 29);
            if(i==1){
                creditText.color = 0xFFf6af29;
            }
            creditText.font = 'assets/fonts/Minecraftia-Regular.ttf';
            creditText.scrollFactor.set();

            mainPage.add(creditText);
        }

        if(character=='PlayableJudge'){
            stats[0] = 'The Judge';
            stats[1] = 'Judge';

            stats[3] = '1';

        }
        for(i in 0...stats.length){
            var statsText = new FlxText(statsPos[i].x, statsPos[i].y, 0, stats[i], 25);
          
            switch(i){
                case 2,5:
                    statsText.color = 0xFFf6af29;

            }
            statsText.font = 'assets/fonts/Minecraftia-Regular.ttf';
            statsText.scrollFactor.set();

            mainPage.add(statsText);
        }
    }
    var num:FlxPoint = new FlxPoint();
    var credits:Array<String>=['0','Credits'];
    var creditsPos:Array<FlxPoint>=[new FlxPoint(273,661),new FlxPoint(299,661)];


    var stats:Array<String>=['The Batter', 'Purifier', 'Lv', '${MapTestState.playerLevel}', 'Pure', 'HP', '${MapTestState.curHealth}/${MapTestState.maxHealth}'];
    var statsPos:Array<FlxPoint>=[
        new FlxPoint(640,48 - 10), 
        new FlxPoint(890,48 -10),
        new FlxPoint(648,105),
        new FlxPoint(696,106),
        new FlxPoint(743,106),
        new FlxPoint(892,105),
        new FlxPoint(940,105)];
    function selectHelper(){
        #if debug
        FlxG.watch.addQuick('num', '${num.x}x ${num.y}y');
        mainPageSelector.setPosition(mainPage.members[curSel].x - num.x, mainPage.members[curSel].y- num.y);
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
      
	override function update(elapsed:Float)
	{
		

		super.update(elapsed);


        switch(character){
            case 'Batter':
                stats[3] = '${MapTestState.playerLevel}';

            case 'PlayableJudge':
                stats[3] = '1';

        }
        
        stats[6] = '${MapTestState.curHealth}/${MapTestState.maxHealth}';
        
        FlxG.watch.addQuick('curPage',curPage);
        FlxG.watch.addQuick('curSel',curSel);

        //selectHelper();
		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;
        if(FlxG.keys.justPressed.ESCAPE){
            //FlxG.switchState(new MainMenuState());
         
          switch(curPage) 
          {
            case 0:
                objectsLayer.destroy();
                trace('killing objects');
            case 1:
                mainPageSelector.alpha=1;

                statusSel.alpha=0;
            case 3:
                quitLayer.destroy();
                trace('killing objects');
            case 10:
                close();



          }

          curPage =10;


      

        }
		if (upP && curPage ==10)
		{
			changeSelection(-1);
		}
		if (downP && curPage ==10)
		{
			changeSelection(1);
		}

	

        if(accepted){
            if(curSel!=curPage)
                {
                    FlxG.sound.play(Paths.sound('Chariot1', 'preload'));

                    switch(curSel){
                    case 0:
                        if(character=='Batter')
                            switchPage(curSel);

                    case 2:
                        //nothing
                    default:
                        switchPage(curSel);

                    }


                }
        }
		
	}

	override function destroy()
	{

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
        FlxG.sound.play(Paths.sound('opchange', 'preload'));

		curSel += change;

		if (curSel < 0)
			curSel = menuItems.length - 1;
		if (curSel >= menuItems.length)
			curSel = 0;


        mainPageSelector.setPosition(mainPage.members[curSel].x - 7, mainPage.members[curSel].y- -3);

	}
}
