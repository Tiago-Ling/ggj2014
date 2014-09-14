package;
import flixel.FlxSprite;
import flixel.util.FlxRandom;

class Powerup extends FlxSprite {
	public var type:Int;
	public function new (X:Float = 0, Y:Float = 0, ?SimpleGraphic:Dynamic) {
		super(X, Y, SimpleGraphic);

		this.loadGraphic("assets/images/weapons.png",true,false,52,52);
		this.animation.add("flames", [0,1],12,true);
		this.animation.add("grenades",[2,3],12,true);
		this.animation.add("random",[4,5],12,true);

		acceleration.set(0, 1600);
		drag.set(0,0);
		maxVelocity.set(0, 800);
		type = 0;
		kill();
	}

	public function activate(x:Float,y:Float):Void {
		this.x = x;
		this.y = y - 52;
		this.velocity.y = -180;
		this.velocity.x = 50;

		if (FlxRandom.chanceRoll()) {
			this.animation.play("flames");
			type = 2;
		} else {
			this.animation.play("grenades");
			type = 1;
		}

		revive();
	}
}