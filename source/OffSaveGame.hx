package;

import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.util.FlxSave;

class OffSaveGame {
    private static var offSave:FlxSave;

    public static function init():Void {
        offSave = new FlxSave();
        offSave.bind("offSave", 'OFFModTeam');
    }

    public static function save(data:SaveData):Void {
        if(offSave.isEmpty()){
            trace('save is empty');
            init();
        }
        offSave.data.batterPos = data.batterPos;
        offSave.data.batterName = data.batterName;
        offSave.data.progress = data.progress;
        offSave.data.maxHealth = data.maxHealth;
        offSave.data.curHealth = data.curHealth;
        offSave.data.playerLevel = data.playerLevel;
        offSave.data.myInventory = data.myInventory;
        offSave.data.currentMap = data.currentMap;
        offSave.data.openedChest = data.openedChest;
        offSave.data.elsenInteractions = data.elsenInteractions;
        offSave.data.skin = data.skin;
        offSave.data.zacharieProgress = data.zacharieProgress;
        offSave.data.cowPets = data.cowPets;

       
        offSave.flush();
    }

    public static function eraseData():Void {
        offSave.erase();
        offSave.destroy();
    }

    public static function loadData():Null<SaveData> {
        if (!offSave.isEmpty()) {
            var data:SaveData = {
                batterPos: offSave.data.batterPos,
                batterName: offSave.data.batterName,
                progress: offSave.data.progress,
                maxHealth: offSave.data.maxHealth,
                curHealth: offSave.data.curHealth,
                playerLevel: offSave.data.playerLevel,
                myInventory: offSave.data.myInventory,
                currentMap: offSave.data.currentMap,
                openedChest: offSave.data.openedChest,
                elsenInteractions: offSave.data.elsenInteractions,
                skin: offSave.data.skin,
                zacharieProgress: offSave.data.zacharieProgress,
                cowPets: offSave.data.cowPets

            };
            return data;
        }
        else {
            return null;
        }
    }
}

typedef SaveData = {
    batterPos: FlxPoint,
    batterName: String,
    progress: Int,
    maxHealth: Int,
    curHealth: Int,
    playerLevel: Int,
    myInventory: PlayerInventory,
    currentMap: String,
    openedChest: Array<Int>,
    elsenInteractions: Int,
    skin: String,
    zacharieProgress:Int,
    cowPets:Int
}

