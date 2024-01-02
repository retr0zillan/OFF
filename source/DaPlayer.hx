package;


import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxSound;
import flixel.util.FlxColor;

using Math;
import states.*;
using flixel.util.FlxArrayUtil;
using flixel.util.FlxSpriteUtil;
import flixel.math.FlxPoint;
enum MoveDirection
{
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

class DaPlayer extends FlxSprite
{
	
	var SPEED:Int =1;
	var usingBody:Bool;

	public var dir:String = 'down';
	public var canMove:Bool = true;

	var directions:Array<String> = ['up', 'down', 'right', 'left'];
	static inline var TILE_SIZE:Int = 16;

	public var autoPilot:Bool = false;
	public function new(x:Float, y:Float, skin:String = 'BatterRPG')
	{
		super(x, y);
		 // Inicializar la variable playerSave
        //makeGraphic(16,16, FlxColor.RED);
		frames = Paths.getSparrowAtlas('rpgshit/${skin}','preload');
		antialiasing = false;
		for(i in 0...directions.length){
			animation.addByPrefix(directions[i], '${skin} ${directions[i]}', 9, true);
			animation.add(directions[i] + '-idle', [animation.getByName(directions[i]).frames[1]], 0, true);

		}

		animation.play('down-idle');
        //animation.add('up-idle', [animation.getByName('up').frames[0]], 0, true);


		
	}

	public var moveToNextTile:Bool;
	var moveDirection:MoveDirection;
	public function moveTo(Direction:MoveDirection):Void
		{
			// Only change direction if not already moving
			if (!moveToNextTile)
			{
				moveDirection = Direction;
				moveToNextTile = true;
		
				dir = Std.string(moveDirection).toLowerCase();
				animation.play(dir);
			}
		}

	function gridMovement(){
		if (moveToNextTile)
			{
				switch (moveDirection)
				{
					case UP:
						y -= SPEED;
					case DOWN:
						y += SPEED;
					case LEFT:
						x -= SPEED;
					case RIGHT:
						x += SPEED;
				}
			}
	
			// Check if the player has now reached the next block
			if ((x % TILE_SIZE == 0) && (y % TILE_SIZE == 0)||!canMove)
			{
				moveToNextTile = false;
			}
	
			
			// Check for WASD or arrow key presses and move accordingly
			if (canMove){
				if (FlxG.keys.anyPressed([ S]))
					{
						moveTo(MoveDirection.DOWN);
				
					}
					else if (FlxG.keys.anyPressed([ W]))
					{
						moveTo(MoveDirection.UP);
					
					}
					else if (FlxG.keys.anyPressed([ A]))
					{
						moveTo(MoveDirection.LEFT);
						
					}
					else if (FlxG.keys.anyPressed([ D]))
					{
						moveTo(MoveDirection.RIGHT);
					
					}
				
					
			}
			
			 if(!FlxG.keys.anyPressed([W,A,S,D])||!canMove)
				animation.play(dir + '-idle');
		

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

              
                animation.play('right');
            } else if (this.velocity.x < 0) {
                // Movimiento hacia la izquierda
                dir= 'left';
                    animation.play('left');
                   
            } else {
                // Sin movimiento
                animation.play(dir + '-idle');
            }
		}
	
	
	

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	

		if(!autoPilot)
			gridMovement();
		else
			nonPhysicalMovement();
			
	
	}
}
