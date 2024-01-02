package states;
import flixel.math.FlxPoint;
import Controls;
import Controls.Control;
import Controls.KeyboardScheme;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.addons.transition.FlxTransitionableState;
import Options;
import flixel.graphics.FlxGraphic;
import ui.*;
using StringTools;

#if desktop
import Discord.DiscordClient;
#end
class OptionsState extends MusicBeatState
{

	public static var instance:OptionsState;
	private var defCat:OptionCategory;

	private var optionText:FlxTypedGroup<Option>;
	private var optionDesc:FlxText;
	private var curSelected:Int = 0;
	public static var category:Dynamic;

	private function createDefault(){
		defCat = new OptionCategory("Default",[
			
			
			new OptionCategory("Controls",[ // TODO: rewrite
				new ControlOption(controls,Control.LEFT),
				new ControlOption(controls,Control.DOWN),
				new ControlOption(controls,Control.UP),
				new ControlOption(controls,Control.RIGHT),
				new ControlOption(controls,Control.PAUSE),

				
			]),
		
				new ToggleOption("downScroll","Downscroll","Arrows come from the top down instead of the bottom up."),
				new ToggleOption("resetKey","Reset key","Toggle pressing the bound key to instantly die"),

				new StateOption("Calibrate Offset",new SoundOffsetState()),
				new ScrollOption("accuracySystem","Accuracy System","How accuracy is determined",0,2,["Basic","SM","Wife3"]),
				new JudgementsOption("judgementWindow","Judgements","The judgement windows to use"),
				//new ToggleOption("ghosttapping","Ghost-tapping","Allows you to press keys while no notes are able to be hit."),
				//new ToggleOption("failForMissing","Sudden Death","FC or die"),
				#if !NO_FREEPLAY_MODS
				//new ToggleOption("fixHoldSegCount","Hold Segment Count Fix","Fixes a bug where holds are smaller than they should be.\nMay cause holds to be longer than they should in old charts."),
			
				#end
				
				// TODO: make a better 'calibrate offset'
			
		
			
			
		]);
	}
	override function create()
	{
		super.create();
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("OPTIONS MENU", null);
		#end
		createDefault();
		if (FlxG.sound.music != null)
			{
				
			}
		category=defCat;
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('optionsBG','preload'));
		menuBG.scrollFactor.set();
		add(menuBG);

		opBar = new FlxSprite(78, 52).loadGraphic(Paths.image('optionBar','preload'));
		opBar.scrollFactor.set();
		add(opBar);

		optionText = new FlxTypedGroup<Option>();
		add(optionText);

		optionDesc = new FlxText(5, FlxG.height-48,0,"",20);
		optionDesc.setFormat(Paths.font("Minecraftia-Regular.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		optionDesc.textField.background=true;
		optionDesc.textField.backgroundColor = FlxColor.BLACK;
		refresh();
		optionDesc.visible=false;
		add(optionDesc);


	}

	var opBar:FlxSprite;
	function refresh(){
		curSelected = category.curSelected;
		optionText.clear();
		for (i in 0...category.options.length)
		{
			optionText.add(category.options[i]);
			var text = category.options[i].createOptionFlxText(curSelected,optionText);
			text.targetY = i;
			text.gotoTargetPosition();
			if(category.options[i].labelAlphabet!=null){
				category.options[i].labelAlphabet.targetY = i;
				category.options[i].labelAlphabet.gotoTargetPosition();
			}
			

		}

		changeSelection(0);
	}

	function changeSelection(?diff:Int=0){
		FlxG.sound.play(Paths.sound('opchange', 'preload'));

		curSelected += diff;

		if (curSelected < 0)
			curSelected = Std.int(category.options.length) - 1;
		if (curSelected >= Std.int(category.options.length))
			curSelected = 0;

		var item = optionText.members[curSelected];

		for (i in 0...optionText.length)
		{
			var item = optionText.members[i];
			item.textFlx.targetY = i-curSelected;

			var wasSelected = item.isSelected;
			item.isSelected=item.textFlx.targetY==0;

			if (item.isSelected)
			{
				//opBar.y = item.textFlx.y;

				item.selected();

				if(item.description!=null && item.description.replace(" ","")!=''){
					optionDesc.visible=true;
					optionDesc.text = item.description;
				}else{
					optionDesc.visible=false;
				}
			}else if(wasSelected){
				item.deselected();
			}
		}
	

		category.curSelected = curSelected;
	}
	var rest:FlxPoint = new FlxPoint();
	function hitBoxHelper(){
        var left=FlxG.keys.pressed.A;
        var right=FlxG.keys.pressed.D;
        var up=FlxG.keys.pressed.W;
        var down=FlxG.keys.pressed.S;

        
        if(left)
            {
                rest.x -= 1;

            }
            if(right)
                {
					rest.x += 1;

                }
                if(up)
                    {
                        rest.y -= 1;

                    }
                    if(down)
                        {
                            rest.y += 1;

                        }
        FlxG.watch.addQuick('shit', 'X${rest.x}|| Y${rest.y}');
		var item = optionText.members[curSelected];
		opBar.setPosition(item.textFlx.x - rest.x,item.textFlx.y-rest.y);

    }
	var coolItem:Dynamic;
	override function update(elapsed:Float)
	{
		//hitBoxHelper();
		FlxG.watch.addQuick('opt', category.options[curSelected].name);

		if(category.options[curSelected].labelAlphabet!=null)
			opBar.setPosition(category.options[curSelected].labelAlphabet.x - rest.x,category.options[curSelected].labelAlphabet.y-rest.y);
		else
			opBar.setPosition(optionText.members[curSelected].textFlx.x - rest.x,optionText.members[curSelected].textFlx.y-rest.y);


		

		var upP = false;
		var downP = false;
		var leftP = false;
		var rightP = false;
		var accepted = false;
		var back = false;
		if(controls.keyboardScheme!=None){
			upP = controls.UP_P;
			downP = controls.DOWN_P;
			leftP = controls.LEFT_P;
			rightP = controls.RIGHT_P;

			accepted = controls.ACCEPT;
			back = controls.BACK;
		}

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		var option = category.options[curSelected];

		if (back)
		{
			if(category!=defCat){
				category.curSelected=0;
				category=category.parent;
				refresh();
			}else{
				FlxG.switchState(new OffMenuState());
				trace("save options");
			  OptionUtils.saveOptions(OptionUtils.options);

			}
		}
		if(option.type!="Category"){
			if(leftP){
				if(option.left()) {
					option.createOptionFlxText(curSelected,optionText);
					changeSelection();
				}
			}
			if(rightP){
				if(option.right()) {
					option.createOptionFlxText(curSelected,optionText);
					changeSelection();
				}
			}
		}

		if(option.allowMultiKeyInput){
			var pressed = FlxG.keys.firstJustPressed();
			var released = FlxG.keys.firstJustReleased();
			if(pressed!=-1){
				if(option.keyPressed(pressed)){
					option.createOptionFlxText(curSelected,optionText);
					changeSelection();
				}
			}
			if(released!=-1){
				if(option.keyReleased(released)){
					option.createOptionFlxText(curSelected,optionText);
					changeSelection();
				}
			}
		}

		if(accepted){
			FlxG.sound.play(Paths.sound('Chariot1', 'preload'));

			trace("shit");
			if(option.type=='Category'){
				category=option;
				refresh();
			}else if(option.accept()) {
				option.createOptionFlxText(curSelected,optionText);
			}
			changeSelection();
			trace("cum");
		}



		if(option.forceupdate){
			option.forceupdate=false;
			//optionText.remove(optionText.members[curSelected]);
			option.createOptionFlxText(curSelected,optionText);
			changeSelection();
		}
		super.update(elapsed);

	}

}
