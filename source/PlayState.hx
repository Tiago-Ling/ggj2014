package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxRandom;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;
import flixel.system.FlxSound;
import flixel.addons.weapon.FlxWeapon;
import flixel.addons.weapon.FlxBullet;
import flixel.util.FlxRect;
import flixel.effects.particles.FlxEmitterExt;
import flixel.ui.FlxBar;
import flixel.tweens.FlxTween;
import flixel.effects.FlxTrail;
/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	var platforms:flixel.group.FlxTypedGroup<Platform>;
	var bossPlats:flixel.group.FlxTypedGroup<Platform>;
	var enemies:flixel.group.FlxTypedGroup<Enemy>;
	var nextPlatformPosition:FlxPoint;
	var weapons:Array<FlxWeapon>;
	var player:FlxSprite;
	var verticalPositions:Array<Float>;
	var lifePanel:FlxSprite;
	var flamethrower:FlxSprite;
	var skyDrop:RunnerBackdrop;
	var cityDrop:RunnerBackdrop;
	var pickups:flixel.group.FlxTypedGroup<Powerup>;
	var timer:FlxTimer;

	var lastPlatformId:Int;
	var timeCounter:Float;
	var isDead:Bool;
	var lives:Int;
	var invincible:Bool;
	var jumpCount:Int;
	var currentWeapon:Int;
	var dropChance:Int;
	var weaponPanel:FlxText;
	var countdownBar:FlxBar;
	var grenadeTrail:FlxTrail;
	var explosion:FlxEmitterExt;
	var boss:FlxSprite;

	var platSpeed:Int;
	var backSpeed:Int;
	var spawnSpeed:Float;
	//If using single jump
	// var jumpSpeed:Int = -950;
	//If using double jump
	var jumpSpeed:Int;
	var bossCounter:Float;
	var bossTime:Bool;
	var bossIsPresent:Bool;

	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		// FlxG.mouse.show();
		#end
		
		super.create();

/*		 FlxG.debugger.drawDebug = true;
		 FlxG.debugger.visible = false;*/

		lastPlatformId = -1;
		nextPlatformPosition = new FlxPoint(-1,-1);
		//For platforms with 450 height
		//verticalPositions = [540, 395, 450, 405, 360];
		//For platforms with 302 height :/
		verticalPositions = [478, 600, 510, 560, 650];
		timeCounter = 0;
		isDead = false;
		lives = 3;
		invincible = false;
		jumpCount = 0;
		currentWeapon = 0;
		platSpeed = -450;
		backSpeed = -250;
		spawnSpeed = 2.5;
		jumpSpeed = -750;
		dropChance = 70;
		bossCounter = 0;
		bossTime = false;
		bossIsPresent = false;

		FlxG.sound.playMusic("assets/music/level_start.mp3",1);
		FlxG.sound.music.onComplete = changeMusic;

		// trace("worldBounds : " + FlxG.worldBounds);
		FlxG.camera.setBounds(0, 0, 10000, 720);
		FlxG.worldBounds.set(0, 0, 10000, 720);

		enemies = new flixel.group.FlxTypedGroup<Enemy>();

		skyDrop = new RunnerBackdrop("assets/images/fundo_ceu.jpg", true, false);
		skyDrop.maxVelocity.x = (backSpeed >> 1) * -1;
		skyDrop.velocity.x = backSpeed >> 1;
		add(skyDrop);

		cityDrop = new RunnerBackdrop("assets/images/meio_cidade.png",true,false);
		cityDrop.y = 284;
		cityDrop.maxVelocity.x = backSpeed * -1;
		cityDrop.velocity.x = backSpeed;
		add(cityDrop);

		var colors:Array<Int> = [0xFFFF6700, 0xFFD435CD, 0xFF1E796A, 0xFF83A000];
		var platGfxs:Array<String> = ["assets/images/plat_516.png",
									  "assets/images/plat_706.png",
									  "assets/images/plat_1174.png",
									  "assets/images/plat_1364.png",
									  "assets/images/plat_1554.png"];
		platforms = new flixel.group.FlxTypedGroup<Platform>();
		//Offset platform y = 60;
		var platCount:Int = 0;
		for (i in 0...20) {
			var p = new Platform(0, 0, null, platSpeed);
			//p.makeGraphic(widths[FlxRandom.intRanged(0, widths.length - 1)], 450, colors[FlxRandom.intRanged(0, colors.length - 1)]);
			p.loadGraphic(platGfxs[platCount],false,false);
			p.offset.x = 20;
			p.width -= 40;
			p.offset.y = 60;
			p.height -= 120;
			p.ID = i;
			p.kill();
			platforms.add(p);
			// add(platforms);
			platCount++;
			if (platCount > 4) platCount = 0;
		}
		add(platforms);

		bossPlats = new flixel.group.FlxTypedGroup<Platform>();
		for (l in 0...30) {
			var p = new Platform(0, 0, null, platSpeed);
			p.loadGraphic("assets/images/plat_1554.png",false,false);
			p.offset.x = 20;
			p.width -= 40;
			p.offset.y = 60;
			p.height -= 120;
			p.ID = l;
			p.kill();
			bossPlats.add(p);
		}
		add(bossPlats);

		enemies = new flixel.group.FlxTypedGroup<Enemy>();
		for (j in 0...30) {
			var e:Enemy = new Enemy(0, 0, null);
			enemies.add(e);
			e.addToState(this);
		}

		pickups = new flixel.group.FlxTypedGroup<Powerup>();
		for (k in 0...20) {
			var p:Powerup = new Powerup(-500,-500);
			pickups.add(p);
			add(p);
		}

		spawnInitialPlatforms();

		player = new FlxSprite(120, 300, null);
		// player.makeGraphic(48, 90, 0xFFFF0000);
		//97x88 WxH
		player.loadGraphic("assets/images/kandy.png",true,false,197,125);
		player.animation.add("run_ft",[0,1,2,3,4,5],12,true);
		player.animation.add("jump_ft",[6,7,8,9,10,11,12],12,false);
		player.animation.add("hit_ft",[13],12,false);
		player.animation.add("die_ft",[14,15,16,17,18,19,20,21],12,false);
		player.animation.add("run_mg",[22,23,24,25,26,27,28,29,30],12,true);
		player.animation.add("jump_mg",[31,32,33,34,35,36],12,false);
		player.animation.add("fall_mg",[37,37,37,37],12,true);
		player.animation.add("hit_mg",[38,38,38,38,38,38,38,38,38,38],1,true);
		player.animation.add("die_mg",[39,39,40,40,41,41,42,42,43,43,44,44,45,45,46,46,46,46,46,46,46],12,false);
		player.animation.play("run_mg");
		
		player.offset.x = 100;
		player.width -= 140;
		player.offset.y = 32;
		player.height -= 48;
		player.acceleration.set(0, 1600);
		player.maxVelocity.set(0, jumpSpeed * -1);
		player.drag.set(0, 0);
		player.collisonXDrag = false;
		add(player);

		weapons = new Array<FlxWeapon>();
		var machineGun:FlxWeapon = new FlxWeapon("machingGun", player);
		// machineGun.makeImageBullet(75,"assets/images/mg_bullet.png",80,38);
		machineGun.makeAnimatedBullet(75,"assets/images/mg_bullet.png",48,14,[0,1,2],12,true,80,38);
		machineGun.setFireRate(200);
		machineGun.setBulletDirection(0,600);
		machineGun.setBulletBounds(new FlxRect(0,0,1280,720));
		machineGun.setBulletAcceleration(0,0,500,0);
		machineGun.setBulletGravity(0,0);
		machineGun.bulletDamage = 1.5;
		var mgSFX:FlxSound = new FlxSound();
		mgSFX.loadEmbedded("assets/sounds/machinegun.wav", false, false);
		mgSFX.volume = 0.3;
		machineGun.setFireCallback(null, mgSFX);
		add(machineGun.group);

		var grenadeLauncher = new FlxWeapon("grenadeLauncher",player);
		// grenadeLauncher.makePixelBullet(20,12,12,0xFFFF4900,80,38);
		grenadeLauncher.makeAnimatedBullet(20,"assets/images/granade.png",57,45,[0,1,2,3],12,true,80,38);
		grenadeLauncher.setFireRate(650);
		grenadeLauncher.setBulletDirection(360,600);
		grenadeLauncher.setBulletBounds(new FlxRect(0,0,1280,720));
		grenadeLauncher.setBulletAcceleration(0,0,1800,200);
		grenadeLauncher.setBulletGravity(0,1800);
		grenadeLauncher.bulletDamage = 3;
		var greSFX:FlxSound = new FlxSound();
		greSFX.loadEmbedded("assets/sounds/gre_launch.wav", false, false);
		greSFX.volume = 0.3;
		grenadeLauncher.setFireCallback(null, greSFX);
		add(grenadeLauncher.group);

		flamethrower = new FlxSprite(0,0);
		flamethrower.loadGraphic("assets/images/flamethrower.png",true,false,109,58);
		flamethrower.animation.add("flames", [0,1,2,3,4,5,6,7],12,false);
		flamethrower.width -=20;
		flamethrower.kill();
		add(flamethrower);

		weapons.push(machineGun);
		weapons.push(grenadeLauncher);

		player.health = 100;
		countdownBar = new FlxBar(0,0,FlxBar.FILL_LEFT_TO_RIGHT,70,15,player,"health",0,100,true);
		countdownBar.trackParent(-10, -35);
		countdownBar.currentValue = 100;
		countdownBar.percent = 100;
		countdownBar.kill();
		add(countdownBar);

		grenadeTrail = new FlxTrail(player,"assets/images/smokeParticle.png",64,2,0.5,0.1);
		grenadeTrail.kill();
		add(grenadeTrail);

		explosion = new FlxEmitterExt(0,0,32);
		explosion.makeParticles("assets/images/granadeBlow.png",50);
		explosion.setScale(0.5,1,1.5,3);
		explosion.setAlpha(0.2,0.4,0.6,0.8);
		// explosion.setMotion(225,32,0.3,270,72,1.2);
		explosion.setMotion(135,32,0.2,270,72,0.7);
		explosion.kill();
		add(explosion);

		lifePanel = new FlxSprite(10, 10);
		lifePanel.loadGraphic("assets/images/vidas.png",true,false,206,81);
		lifePanel.animation.add("3",[0],0,false);
		lifePanel.animation.add("2",[1],0,false);
		lifePanel.animation.add("1",[2],0,false);
		lifePanel.animation.add("0",[3],0,false);
		lifePanel.scrollFactor = new FlxPoint(0,0);
		add(lifePanel);

		var txt:String;
		switch (currentWeapon) {
			case 0:
				txt = "Weapon: Machine Gun";
			case 1:
				txt = "Weapon: Grenade Launcher";
			case 2:
				txt = "Weapon: Flamethrower";
			default:
				txt = "Weapon: Machine Gun";
		}
		weaponPanel = new FlxText(820, 10, 450, txt, 18);
		weaponPanel.scrollFactor = new FlxPoint(0,0);
		weaponPanel.borderStyle = FlxText.BORDER_OUTLINE;
		weaponPanel.borderColor = 0xFF000000;
		weaponPanel.borderSize = 1;
		weaponPanel.alignment = "right";
		add(weaponPanel);
	}

	function spawnInitialPlatforms():Void {
		var p = platforms.members[4];
		p.setPosition(0, 630);
		lastPlatformId = p.ID;
		p.revive();

		spawnNewPlatform();
		spawnNewPlatform();
		spawnNewPlatform();
	}

	function spawnNewPlatform():Void {
		var p = platforms.recycle();
		setNextPlatformPosition(p);
		lastPlatformId = p.ID;
		p.revive();
		spawnEnemies(lastPlatformId);
	}

	function spawnFirstBossPlats():Void {
		//trace("Spawning FIRST boss Platform");
		var p = bossPlats.recycle();
		p.x = (platforms.members[lastPlatformId].x + platforms.members[lastPlatformId].width) + 64;
		p.y = 650;
		lastPlatformId = p.ID;
		p.revive();
	}

	function spawnBossPlatform():Void {
		var p = bossPlats.recycle();
		p.x = (bossPlats.members[lastPlatformId].x + bossPlats.members[lastPlatformId].width) + 64;
		p.y = 650;
		lastPlatformId = p.ID;
		p.revive();
	}

	function setNextPlatformPosition(p:Platform):Void {
		var lastPlatformHPos:Int = Std.int(platforms.members[lastPlatformId].x);
		var horizontalPos:Float = (lastPlatformHPos + platforms.members[lastPlatformId].width) + (FlxRandom.intRanged(1, 5) * 50) + 50;
		var verticalPos:Float = verticalPositions[FlxRandom.intRanged(0, verticalPositions.length - 1)];
		p.x = horizontalPos;
		p.y = verticalPos;
	}

	function spawnEnemies(platId:Int):Void {
		var numEnemies = FlxRandom.intRanged(1,4);
		// trace("spawnEnemies : " + numEnemies);
		//TODO: Prevent enemies from spawning onto each other
		var pSlots:Int = Std.int(platforms.members[platId].width / 64);
		var usedSlots:Array<Int> = [];
		for (i in 0...numEnemies) {
			var chosenSlot:Int = FlxRandom.intRanged(0, pSlots, usedSlots);
			usedSlots.push(chosenSlot);
			var spawnX:Float = platforms.members[platId].x + (chosenSlot * 64) - 32;
			var spawnY:Float = platforms.members[platId].y - 150;
			var e:Enemy = enemies.recycle();
			// trace("Spawn at : " + spawnX + "," + spawnY + " | isAlive : " + e.alive);
			e.setPosition(spawnX,spawnY);
			e.activate();
		}
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		platforms.kill();
		enemies.kill();
		player.kill();
		skyDrop.kill();
		cityDrop.kill();

		weaponPanel.kill();
		countdownBar.kill();
		grenadeTrail.kill();
		explosion.kill();

		lifePanel.kill();
		flamethrower.kill();
		pickups.kill();
		bossPlats.kill();

		platforms = null;
		enemies = null;
		player = null;
		skyDrop = null;
		cityDrop = null;
		verticalPositions = null;

		weaponPanel = null;
		countdownBar = null;
		grenadeTrail = null;
		explosion = null;

		lifePanel = null;
		flamethrower = null;
		pickups = null;
		bossPlats = null;

		for (w in weapons) {
			// w.kill();
			w = null;
		}

		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();

		checkCollisions();

		if (isDead) {
			return;
		}

		checkTimer();

		flamethrower.setPosition(player.x + 96, player.y + 2);

		handleInputs();

		checkDeathConditions();
	}

	function checkDeathConditions():Bool {

		if (player.x <= -player.width || player.y >= FlxG.height) {
			isDead = true;
			stopLevel();
		}

		//TODO: No lives left
		if (lives < 1) {
			isDead = true;
			player.animation.play("die_mg",true);
			stopLevel();
		}

		return isDead;
	}

	function checkTimer():Void {
		timeCounter += FlxG.elapsed;

		if (!bossTime)
			bossCounter += FlxG.elapsed;

		if (bossCounter > 60) {
			bossTime = true;
			bossCounter = 0;
			spawnFirstBossPlats();
			spawnSpeed = 1.2;
		}

		if (timeCounter > spawnSpeed) {

			// bossTime ? spawnBossPlatform() : spawnNewPlatform();
			if (bossTime == true) {
				spawnBossPlatform();
				if (!bossIsPresent) {
					spawnBoss();
					bossIsPresent = true;
				}
			} else {
				spawnNewPlatform();
			}

			timeCounter = 0;
		}
	}

	function spawnBoss():Void {
		var platCenter:FlxPoint = bossPlats.members[lastPlatformId].getMidpoint();

		boss = new FlxSprite(platCenter.x - 132, platCenter.y - 500);
		boss.kill();
		boss.loadGraphic("assets/images/boss_33.png",true,false,264,132);

		boss.acceleration.set(0, 1600);
		boss.drag.set(0,0);
		boss.maxVelocity.set(0, 800);
		boss.velocity.x = -25;

		boss.animation.add("run",[3,2,1],12,true);
		boss.animation.add("defense",[0],12,true);
		boss.animation.add("attackA",[7,6],12,true);
		boss.animation.add("attackB",[5,4],12,true);
		boss.animation.play("run");
		add(boss);
		FlxTimer.start(1.5,reviveBoss);
	}

	function reviveBoss(timer:FlxTimer):Void {
		var platCenter:FlxPoint = bossPlats.members[lastPlatformId].getMidpoint();
		boss.setPosition(platCenter.x - 400, platCenter.y - 702);
		// boss.setPosition(640, 0);
		//trace("Boss position : " + boss.x + "," + boss.y);
		boss.revive();
	}

	function handleInputs():Void {
		if (FlxG.keys.justPressed.SPACE && jumpCount < 2) {
			player.velocity.y = jumpSpeed;
			jumpCount++;
			player.animation.play("jump_mg");
			FlxG.sound.play("assets/sounds/jump.wav");
			player.animation.callback = onJumpEnd;
		}


		if (FlxG.keys.pressed.CONTROL && currentWeapon != 2) {
			weapons[currentWeapon].fire();
			if (currentWeapon == 1) {
				grenadeTrail.sprite = weapons[currentWeapon].currentBullet;
				grenadeTrail.resetTrail();
				grenadeTrail.revive();
			}
		}

		if (FlxG.keys.justPressed.CONTROL && currentWeapon == 2) {
			flamethrower.revive();
			flamethrower.animation.play("flames");
			FlxTimer.start(0.7, deactivateFlames);
			FlxG.sound.play("assets/sounds/flamethrower.wav");
		}
	}

	function checkCollisions():Void {
		// if (!bossTime) {
		// 	FlxG.collide(player, platforms, resetJump);
		// } else {
		// 	FlxG.collide(player, bossPlats, resetJump);
		// }
		FlxG.collide(player, platforms, resetJump);

		if (bossTime) {
			FlxG.collide(player, bossPlats, resetJump);
			FlxG.collide(boss, bossPlats);
		}

		FlxG.overlap(player,pickups,collectPowerup);
		FlxG.overlap(player, enemies, decrementPlayerLife);
		FlxG.collide(enemies, platforms);

		if (currentWeapon == 2) {
			FlxG.overlap(flamethrower, enemies, burnEnemies);
		} else {
			FlxG.collide(weapons[currentWeapon].group, enemies, damageEnemy);
			FlxG.collide(weapons[currentWeapon].group, platforms, killBullet);
		}

		FlxG.collide(pickups,platforms);
	}

	function decrementPlayerLife(Object1:FlxObject, Object2:FlxObject):Void {
		if (!invincible) {
			lives--;
			lifePanel.animation.play(Std.string(lives));

			FlxG.camera.flash(0xFFFFFFFF,0.1);
			FlxSpriteUtil.flicker(player, 2, 0.1);
			//TODO: Play sound effect

			invincible = true;
			player.animation.play("hit_mg",true);
			flixel.util.FlxTimer.start(2, resetInvincibility);
		}
	}

	function resetInvincibility(timer:FlxTimer):Void {
		invincible = false;
		player.animation.play("run_mg");
	}

	function resetJump(Object1:FlxObject, Object2:FlxObject):Void {
		if (player.animation.curAnim.name == "fall_mg") {
			player.animation.play("run_mg");
		}
		jumpCount = 0;
	}

	function changeMusic():Void {
		FlxG.sound.playMusic("assets/music/level_loop.mp3",1);
		FlxG.sound.music.onComplete = null;
	}

	function damageEnemy(b:FlxObject, e:FlxObject):Void {
		if (currentWeapon == 1) {
			grenadeTrail.resetTrail();
			grenadeTrail.kill();
			doExplode(b.x, b.y);
		}

		b.kill();
		var enemy = cast(e, Enemy);
		if (weapons[currentWeapon].bulletDamage >= enemy.life) {
			checkEnemyDrop(enemy);
		}
		enemy.doDamage(weapons[currentWeapon].bulletDamage);
	}

	function checkEnemyDrop(e:Enemy):Void {
		// if (FlxRandom.chanceRoll(dropChance) && e.active){
		if (FlxRandom.chanceRoll(dropChance)){
			var p = pickups.recycle();
			p.activate(e.x, e.y);
		}
	}

	function activateTimeBar():Void {
		//trace("Activate Time Bar");
		player.health = 100;
		countdownBar.currentValue = 100;
		countdownBar.revive();
		// timer.start(0.1,reduceBar, 100);
		if (timer == null) {
			timer = FlxTimer.start(0.1, reduceBar, 100);
		} else {
			timer.abort();
			timer = FlxTimer.start(0.1, reduceBar, 100);
		}
	}

	function reduceBar(timer:FlxTimer):Void {
		player.health -= 1;
		if (player.health == 0) {
			resetWeapon();
		}
	}

	function resetWeapon():Void {
		//trace("Reset Weapon");
		currentWeapon = 0;
		countdownBar.kill();
	}

	function collectPowerup(pl:FlxObject,pi:FlxObject):Void {
		currentWeapon = cast(pi, Powerup).type;
		// trace("Got an item : " + currentWeapon);
		pi.kill();
		pi.setPosition(-500,-500);
		if (currentWeapon == 1) {
			weaponPanel.text = "Weapon: Grenade Launcher";
		} else {
			weaponPanel.text = "Weapon: Flamethrower";
		}
		activateTimeBar();
	}

	function killBullet(b:FlxObject, e:FlxObject):Void {
		if (currentWeapon == 1) {
			grenadeTrail.resetTrail();
			grenadeTrail.kill();
			doExplode(b.x, b.y);
		}

		b.kill();
	}

	function doExplode(x:Float, y:Float):Void {
		explosion.x = x;
		explosion.y = y;
		// explosion.start(true,0.3,10,50,0.8);
		explosion.start(true, 0.1, 12, 50, 0.6);
		FlxG.sound.play("assets/sounds/gre_explosion.wav", 0.6);
	}

	function onJumpEnd(name:String, fNumber:Int, fIndex:Int):Void {
		if (name == "jump_mg" && fIndex == 36) {
			player.animation.play("fall_mg");
		}
	}

	function burnEnemies(ft:FlxObject, e:FlxObject):Void {
		cast(e, Enemy).doDamage(3);
	}

	function deactivateFlames(timer:FlxTimer):Void {
		timer = null;
		flamethrower.kill();
	}

	function stopLevel():Void {
		for (p in platforms.members) {
			p.velocity.x = 0;
		}

		skyDrop.velocity.x = 0;
		cityDrop.velocity.x = 0;

		FlxTimer.start(1,resetLevel);
	}

	function resetLevel(timer:FlxTimer):Void {
		timer = null;
		FlxG.camera.fade(0xFF000000,0.5,false,FlxG.resetState);
	}
}