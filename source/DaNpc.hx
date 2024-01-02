package;


import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.path.FlxPath;

using Math;
import states.*;
using flixel.util.FlxArrayUtil;
using flixel.util.FlxSpriteUtil;

class DaNpc extends FlxSprite
{
	public var SPEED:Int = 80;
	var usingBody:Bool;

	public var dir:String = 'down';
	public var canMove:Bool = true;

    public var forcedAnim:Bool;
	var directions:Array<String> = ['up', 'down', 'right', 'left'];
    var name:String;
	public function new(x:Float, y:Float, name:String, ?path:FlxPath, ?forcedAnim:Bool = false)
	{
		super(x, y);

        this.name = name;
        this.path = path;
        this.forcedAnim = forcedAnim;
        //makeGraphic(16,16, FlxColor.RED);
       
        frames = Paths.getSparrowAtlas('rpgshit/${name}','preload');
       


        switch(name){

            case 'JaphetRPG':

                var anims = ['up', 'down', 'walk', 'sit'];

                for(i in 0...anims.length){
                    animation.addByPrefix(anims[i], 'JaphetRPG ${anims[i]}', 7, true);
                    animation.add(anims[i] + '-idle', [animation.getByName(anims[i]).frames[1]], 0, true);

                }
                default:
                    var anims = ['up', 'down', 'right', 'left'];
                    for(i in 0...anims.length){
                        animation.addByPrefix(anims[i], '${name} ${anims[i]}', 7, true);
                        animation.add(anims[i] + '-idle', [animation.getByName(anims[i]).frames[1]], 0, true);
    
                    }

        }
        /*
		for(i in 0...directions.length){
			animation.addByPrefix(directions[i], 'BatterRPG ${directions[i]}', 7, true);
			animation.add(directions[i] + '-idle', [animation.getByName(directions[i]).frames[1]], 0, true);

		}

        */

        //animation.add('up-idle', [animation.getByName('up').frames[0]], 0, true);

		
	
	}


	function nonPhysicalMovement()
		{
			
			if (this.velocity.y < 0) {
                // Movimiento hacia arriba
                dir= 'up';
                animation.play('up');
            } else if (this.velocity.y > 0) {
                // Movimiento hacia abajo
                dir= 'down';

                animation.play('down');
            } else if (this.velocity.x > 0) {
                // Movimiento hacia la derecha
                dir= 'right';

                if(name!='JaphetRPG')
                animation.play('right');
                else
                    {
                        this.flipX = false;

                        animation.play('walk');

                    }

            } else if (this.velocity.x < 0) {
                // Movimiento hacia la izquierda
                dir= 'left';

                
                if(name!='JaphetRPG')
                    animation.play('left');
                    else
                        {
                            this.flipX = true;
    
                            animation.play('walk');
    
                        }
            } else {
                // Sin movimiento
                animation.play(dir + '-idle');
            }
		}
	

	

	override function update(elapsed:Float)
	{
		super.update(elapsed);
        if(!forcedAnim)
        nonPhysicalMovement();

	
			
	
	}
}
