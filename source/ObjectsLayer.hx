package;

import Controls.Control;
import flixel.FlxG;
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
import states.*;
using StringTools;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;
import PlayerInventory;
class ObjectsLayer extends FlxSpriteGroup
{
    public static var inventory:PlayerInventory;
    var itemNameTexts:Array<FlxText>;
    var itemQuantityTexts:Array<FlxText>;
    var descriptionText:FlxText;
    var selectedIndex:Int;
    private var controls(get, never):Controls;
	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
    var itemBar:FlxSprite;
    var bars:FlxSprite;

	public function new()
	{
		super();

		inventory = MapTestState.myInventory;

        selectedIndex = 0;
        itemNameTexts = [];
        itemQuantityTexts = [];
        descriptionText = new FlxText(194, 47, 0, "", 29);
        descriptionText.font = 'assets/fonts/Minecraftia-Regular.ttf';


        var bg = new FlxSprite().loadGraphic(Paths.image('pauseMenu/objectsPage', 'preload'));
        add(bg);

        itemBar = new FlxSprite(186,169).loadGraphic(Paths.image('pauseMenu/itemBar', 'preload'));
		itemBar.scrollFactor.set();
		add(itemBar);

        // Crea los textos para mostrar los items y cantidades
        for (i in 0...inventory.items.length) {
            var item = inventory.items[i];
            var itemNameText = new FlxText(213, 180 + i * 50, 0, item.name, 29);
            var itemQuantityText = new FlxText(610, 180 + i * 50, 0, ':${item.quantity}', 29);
            itemNameText.font = 'assets/fonts/Minecraftia-Regular.ttf';
            itemQuantityText.font = 'assets/fonts/Minecraftia-Regular.ttf';

            itemNameTexts.push(itemNameText);
            itemQuantityTexts.push(itemQuantityText);
            add(itemNameText);
            add(itemQuantityText);
        }

        add(descriptionText);

		//cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

        bars = new FlxSprite(0,0).loadGraphic(Paths.image('BlackBars1280', 'preload'));
        bars.scrollFactor.set();
        add(bars);

        changeItem();
        
	}
    
    private function updateDescriptionText():Void {
        if (selectedIndex >= 0 && selectedIndex < itemNameTexts.length) {
            var selectedItemNameText = itemNameTexts[selectedIndex];
            var selectedItemQuantityText = itemQuantityTexts[selectedIndex];
            var itemName:String = selectedItemNameText.text;
            var selectedItem = inventory.findItemByName(itemName);
            if (selectedItem != null) {
                descriptionText.text = selectedItem.description;
            } else {
                descriptionText.text = "";
            }
        } else {
            descriptionText.text = "";
        }
    }
    var Deciding:Bool= false;
    function changeItem(owo:Int=0){
        selectedIndex+=owo;
        if (selectedIndex < 0) {
            selectedIndex = itemNameTexts.length - 1;
        }
        if (selectedIndex >= itemNameTexts.length) {
            selectedIndex = 0;
        }
        if(inventory.items.length>0)
        itemBar.setPosition(itemNameTexts[selectedIndex].x - 27, itemNameTexts[selectedIndex].y - 11);

        updateDescriptionText();

        //27x 11y
    }

    var num:FlxPoint = new FlxPoint();

    function selectHelper(){
        #if debug
        FlxG.watch.addQuick('num', '${num.x}x ${num.y}y');
        itemBar.setPosition(itemNameTexts[selectedIndex].x - num.x, itemNameTexts[selectedIndex].y - num.y);
        if (FlxG.keys.pressed.LEFT) {
            num.x -= 1;
        }
        if (FlxG.keys.pressed.RIGHT) {
            num.x += 1;
        }
        if (FlxG.keys.pressed.UP) {
            num.y -= 1;
        }
        if (FlxG.keys.pressed.DOWN) {
            num.y += 1;
        }
        //scalePortrait();
        #end
    }

    var skinMap:Map<String,String>=[

        'Supervisor Suit'=>'BatterRPGsuit',
        'Switch'=>'BatterRPGbad',
        'Mysterious Comic'=>'BatterRPGshadow',
    ];
    var itemName:String;

    override function update(elapsed:Float)
	{
        //selectHelper();

        FlxG.watch.addQuick('barPos', 'x: ${itemBar.x} y: ${itemBar.y}');
            if (controls.UP_P && !Deciding) {
                changeItem(-1);
            }
            if (controls.DOWN_P && !Deciding) {
                changeItem(1);
            }
     
      
        if (controls.ACCEPT && !Deciding) {
            if (selectedIndex >= 0 && selectedIndex < itemNameTexts.length) {
                var selectedItemNameText = itemNameTexts[selectedIndex];
                 itemName = selectedItemNameText.text;
                var selectedItem = inventory.findItemByName(itemName);

                if(inventory.countEquippedItems()>1){
                    for(im in inventory.items){
                        if(im.isEquipable){
                            im.equipped = false;
                        }
                    }
                }
                
              if(!selectedItem.isEquipable)
                    yes = 'Use this item?';
                else{
                    if(selectedItem.equipped)
                    yes = 'Unequip this item?';
                    else
                        yes = 'Equip this item?';


                }

                if(MapTestState.wentoPs){
                    if(!selectedItem.isKeyObject && !selectedItem.isEquipable){
                        useItem(selectedItem);
                    }
                }
                else{
                    if(!selectedItem.isKeyObject){
                        useItem(selectedItem);
                    }
                }
                
                

            }
        }
      
        
        super.update(elapsed);
	}
    var yes:String;

    function useItem(selectedItem:Item){
      
            Deciding = true;
            var options = new CoolDecision(['Yes', 'No'], Bottom, yes);
        
            options.box.alpha = .70;
            //options.cameras = [camHUD];

            add(options);
            options.finishThing = function(){
                switch(options.curSel){
                    case 0:
                      
                    updateItem();
                     
                      
                        trace('total equipped items is ${inventory.countEquippedItems()}');
                        if(selectedItem.isEquipable){
                            
                            if(selectedItem.equipped)
                                MapTestState.skin = skinMap.get(itemName);
                                else
                                    MapTestState.skin = 'BatterRPG';

                                MapTestState.lastKnownPos.set( MapTestState.instance.player.x,  MapTestState.instance.player.y);

                                MapTestState.instance.reloadPlayer();

                              
                              
                                
                                trace('${selectedItem.name} is now ${selectedItem.equipped}');
                        }
                               
                          
                       
                    case 1:

                }
                new FlxTimer().start(0.7, function(_){
                    Deciding = false;

                });
            }
        
    }
    function updateItem(){
        var selectedItemNameText = itemNameTexts[selectedIndex];
        var selectedItemQuantityText = itemQuantityTexts[selectedIndex];
        var itemName:String = selectedItemNameText.text;

        // Usa el item seleccionado
        inventory.useItem(itemName);
        var selectedItem = inventory.findItemByName(itemName);

       
        // Actualiza la cantidad mostrada en el texto
        if(!selectedItem.isEquipable){
            trace('removing item');
            if (selectedItem != null) {
                if (selectedItem.quantity > 0) {
                    selectedItemQuantityText.text = ':${selectedItem.quantity}';
                } else {
                    inventory.removeItem(selectedItemNameText.text);
    
                    selectedItemNameText.text = "";
                    selectedItemQuantityText.text = "";
                    removeItemText(selectedIndex);
                    selectedIndex = Std.int(Math.min(selectedIndex, itemNameTexts.length - 1));
                    updateDescriptionText();
                }
            } else {
                inventory.removeItem(selectedItemNameText.text);
    
                selectedItemNameText.text = "";
                selectedItemQuantityText.text = "";
                removeItemText(selectedIndex);
                selectedIndex = Std.int(Math.min(selectedIndex, itemNameTexts.length - 1));
                updateDescriptionText();
            }
        }
       
    }
    function removeItemText(index:Int):Void {
        var itemNameText = itemNameTexts[index];
        var itemQuantityText = itemQuantityTexts[index];

        itemNameTexts.splice(index, 1);
        itemQuantityTexts.splice(index, 1);

        remove(itemNameText);
        remove(itemQuantityText);

        // Ajustar la posición de los demás items hacia arriba
        for (i in index...itemNameTexts.length) {
            var itemText = itemNameTexts[i];
            var quantityText = itemQuantityTexts[i];
            itemText.y -= 50;
            quantityText.y -= 50;
        }
    }
}