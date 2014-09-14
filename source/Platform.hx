package;
import flixel.FlxSprite;

class Platform extends FlxSprite {
	
	override public function new (X:Float = 0, Y:Float = 0, ?SimpleGraphic:Dynamic, ?speed:Float) {
		super(X, Y, SimpleGraphic);

		// collisonXDrag = false;
		velocity.x = speed;
		maxVelocity.set(speed * -1, 0);
		acceleration.set(0,0);
		immovable = true;
		drag.set(0, 0);
	}

	override public function update():Void {
		super.update();

		if (this.x <= -this.width) {
			kill();
		}
	}
}