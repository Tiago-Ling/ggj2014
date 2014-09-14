package ;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

class RunnerBackdrop extends FlxBackdrop
{
	override public function draw():Void {
		x %= _scrollW;

		super.draw();
	}
}