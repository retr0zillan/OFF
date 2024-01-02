import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import states.*;
import ui.*;
using StringTools;

typedef Item = { name:String, quantity:Int, description:String, isEquipable:Bool, equipped:Bool, isKeyObject:Bool };

class PlayerInventory {
    // Estructura para almacenar los objetos del inventario
    public var items:Array<Item>;

    public function new() {
        items = new Array<Item>();
    }

    // Agregar un objeto al inventario
    public function addItem(name:String, quantity:Int = 1, description:String, isEquipable:Bool = false, isKeyObject:Bool = false):Void {
        var existingItem = findItemByName(name);
        if (existingItem != null) {
            existingItem.quantity += quantity;
        } else {
            items.push({ name: name, quantity: quantity, description: description, isEquipable: isEquipable, equipped: false, isKeyObject:isKeyObject });
        }
    }
    
    public function removeItem(name:String):Void {
        var existingItem = findItemByName(name);
        if (existingItem != null) {
            items.remove(existingItem);
            trace("Eliminaste el objeto: " + name);
        } else {
            trace("No tienes ese objeto en tu inventario.");
        }
    }
    
    // Usar un objeto del inventario y descartarlo o equiparlo/desequiparlo
    public function useItem(name:String):Void {
        var existingItem = findItemByName(name);
        if (existingItem != null) {
            if(existingItem.isKeyObject){
                trace('nope');
            }
            else if (existingItem.isEquipable) {
                existingItem.equipped = !existingItem.equipped;
                if (existingItem.equipped) {
                    trace("Has equipado el objeto: " + name);
                } else {
                    trace("Has desequipado el objeto: " + name);
                }
            } else {
                if (existingItem.quantity > 0) {
                    switch(name){
                        case 'Lucky ticket':
                            MapTestState.curHealth += 50;
                            if(MapTestState.curHealth>MapTestState.maxHealth){
                                MapTestState.curHealth = MapTestState.maxHealth;
                            }
                        case 'Fortune ticket':
                            MapTestState.curHealth += 100;
                            if(MapTestState.curHealth>MapTestState.maxHealth){
                                MapTestState.curHealth = MapTestState.maxHealth;
                            }
                        case 'Chunk of meat':
                            MapTestState.curHealth += 170;
                            if(MapTestState.curHealth>MapTestState.maxHealth){
                                MapTestState.curHealth = MapTestState.maxHealth;
                            }
                            case "Meat Drumstick":
                            MapTestState.curHealth = MapTestState.maxHealth;
                           
                    }
                    
                    existingItem.quantity--;
                    // Lógica adicional para utilizar el objeto consumible
                    trace("Usaste un objeto consumible: " + name);
                } else {
                    trace("No tienes más objetos de ese tipo.");
                }
            }
        } else {
            trace("No tienes ese objeto en tu inventario.");
        }
    }

    // Buscar un objeto en el inventario por su nombre
    public function countEquippedItems():Int{
        var counter:Int = 0;
        for (item in items) {
           if(item.isEquipable && item.equipped){
            counter++;
           }
        }
        return counter;
    }
    public function findItemByName(name:String):Null<Item> {
        for (item in items) {
            if (item.name == name) {
                return item;
            }
        }
        return null;
    }

    // Clonar el inventario
    public function clone():PlayerInventory {
        var clonedInventory = new PlayerInventory();
        for (item in items) {
            var clonedItem = { name: item.name, quantity: item.quantity, description: item.description, isEquipable: item.isEquipable, equipped: item.equipped, isKeyObject:item.isKeyObject};
            clonedInventory.items.push(clonedItem);
        }
        return clonedInventory;
    }
}