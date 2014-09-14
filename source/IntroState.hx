package;

import flash.display.MovieClip;
import flash.Lib;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import motion.Actuate;
import openfl.Assets;

/**
 * A FlxState which can be used for the game's menu.
 */
class IntroState extends FlxState
{
	var intro:MovieClip;
	var startingGame:Bool;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		
		startingGame = false;
		
		super.create();
		
		Assets.loadLibrary("intro", onIntroLoaded);
	}
	
	function onIntroLoaded(lib:AssetLibrary):Void 
	{
		intro = Assets.getMovieClip("intro:");
		Lib.current.addChild(intro);
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		
		handleControls();
	}	
	
	function handleControls() 
	{
		if (FlxG.keys.justPressed.SPACE && !startingGame) {
			startingGame = true;
			Actuate.transform(intro, 1).color(0x000000, 1).onComplete(showMenu);
			intro.stop();
			FlxG.sound.play("assets/music/intro_start.wav");
		}
	}
	
	function showMenu() 
	{
		trace("showMenu");
	}
}