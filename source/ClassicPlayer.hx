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

class ClassicPlayer extends FlxSprite
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
						dir = 'down';
					}
					else if (FlxG.keys.anyPressed([ W]))
					{
						moveTo(MoveDirection.UP);
						dir = 'up';
					}
					else if (FlxG.keys.anyPressed([ A]))
					{
						moveTo(MoveDirection.LEFT);
						dir = 'left';
					}
					else if (FlxG.keys.anyPressed([ D]))
					{
						moveTo(MoveDirection.RIGHT);
						dir = 'right';
					}
					
			}
			
			if(moveToNextTile)
			animation.play(dir);
			else
				animation.play(dir + '-idle');

	}
		/*
	function physicalMovement()
		{
			var left = FlxG.keys.anyPressed([A]);
			var right = FlxG.keys.anyPressed([D]);
			var shift = FlxG.keys.anyPressed([SHIFT]);
			var up = FlxG.keys.anyPressed([W]);
			var down = FlxG.keys.anyPressed([S]);
		
			drag.x = 0;
			drag.y = 0;
			if (canMove)
			{
				if ((right && left) || (up && down))
				{
					velocity.x = 0;
					velocity.y = 0;
				}
				else if (right)
				{
					velocity.x = SPEED;
					dir = 'right';
				}
				else if (left)
				{
					velocity.x = -SPEED;
					dir = 'left';
				}
				else if (up)
				{
					velocity.y = -SPEED;
					dir = 'up';
				}
				else if (down)
				{
					velocity.y = SPEED;
					dir = 'down';
				}
			}
		
			if (velocity.y != 0 || velocity.x != 0)
			{
				animation.play(dir);
			}
			else
			{
				animation.play(dir + '-idle');
			}
		}
	

		*/
	

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	

		
			gridMovement();

			
	
	}
}
