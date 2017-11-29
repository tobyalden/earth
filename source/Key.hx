package;

import flixel.*;
import flixel.system.*;
import flixel.util.*;

class Key extends FlxSprite
{
    private var unlockSfx:FlxSound;

    public function new(x:Int, y:Int) {
        super(x, y);
        loadGraphic('assets/images/key.png');
        unlockSfx = FlxG.sound.load('assets/sounds/key.ogg');
    }

    override public function kill()
    {
        unlockSfx.play(true);
        super.destroy();
    }
}
