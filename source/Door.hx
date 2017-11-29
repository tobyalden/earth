package;

import flixel.*;
import flixel.system.*;
import flixel.util.*;

class Door extends FlxSprite
{
    public var leaveSfx:FlxSound;

    public function new(x:Int, y:Int) {
        super(x, y);
        loadGraphic('assets/images/door.png', true, 32, 32);
        animation.add('closed', [0]);
        animation.add('open', [1]);
        animation.play('closed');
        leaveSfx = FlxG.sound.load('assets/sounds/door.ogg');
    }
}
