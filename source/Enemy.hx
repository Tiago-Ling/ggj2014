package;
import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil;
import flixel.FlxState;
import flixel.util.FlxTimer;

class Enemy extends FlxSprite {
	
	public var life:Float = 3;
	var emitter:flixel.effects.particles.FlxEmitterExt;
	// var state:flixel.FlxState;

	public function new (X:Float = 0, Y:Float = 0, ?SimpleGraphic:Dynamic) {
		super(X, Y, SimpleGraphic);

		// makeGraphic(32,64,0xFF00FF00);
		this.loadGraphic("assets/images/monstro2.png", true, false, 58, 83);
		
		this.offset.x = 5;
		this.width -= 10;
		
		this.offset.y = 7;
		this.height -= 14;
		
		this.animation.add("walk",[0,1,2,3,4,5],12,true);
		acceleration.set(0, 1600);
		drag.set(0,0);
		maxVelocity.set(0, 800);
		velocity.x = -25;

		emitter = new flixel.effects.particles.FlxEmitterExt(this.x + 16, this.y + 16, 32);
		emitter.makeParticles("assets/images/blood_splat.png",75,16,false);

		emitter.kill();
		kill();
	}

	public function doDamage(dmg:Float):Void {
		life -= dmg;
		
		// FlxSpriteUtil.flicker(this,0.2,0.04);
		// this.x -= 8;

		if (life <= 0) {
			//TODO: Use emitter or play animation
			emitter.x = this.x + 16;
			emitter.y = this.y + 16;
			emitter.setMotion(-60,48,0.25,60,64,0.5);
			emitter.setXSpeed(3000, 5000);
			emitter.gravity = 100;
			emitter.start(true,0.2,0,100,0.4);
			// this.active = false;
			this.solid = false;

			flixel.util.FlxTimer.start(0.3,deactivate);
		} else {
			emitter.x = this.x + 16;
			emitter.y = this.y + 16;
			emitter.setMotion(0,48,0.25,60,64,0.5);
			emitter.setXSpeed(3000, 5000);
			emitter.gravity = 100;
			emitter.start(true,0.2,0,15,0.4);
		}
	}

	public function addToState(state:FlxState):Void {
		state.add(this);
		state.add(emitter);
	}

	public function activate():Void {
		this.revive();
		emitter.revive();
		solid = true;
		acceleration.set(0, 1600);
		maxVelocity.set(0, 800);
		this.animation.play("walk");
	}

	public function deactivate(timer:FlxTimer):Void {
		FlxTimer.start(1,disableEmitter);
		this.active = true;
		this.kill();
		acceleration.set(0, 0);
		maxVelocity.set(0, 0);
		life = 3;

	}

	function disableEmitter(timer:FlxTimer):Void {
		emitter.kill();
	}

	override public function update():Void {
		super.update();
		
		this.velocity.x = -25;

		if (this.x <= -this.width || this.y >= 720) {
			this.kill();
			emitter.kill();
			life = 3;
			acceleration.set(0, 0);
			maxVelocity.set(0, 0);
		}
	}
}