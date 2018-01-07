package;

import flixel.*;
import flixel.util.*;

class LevelDeco extends FlxSprite
{
    public function new(x:Int, y:Int) {
        super(x, y);
        loadGraphic('assets/images/leveldeco.png', true, 320, 240);
        animation.add('idle', [
            5, 6, 7, 8, 9, 10, 11, 1, 2, 3, 2, 1, 11, 10, 9, 8, 7, 6
        ], 12);
        animation.play('idle');
    }
}
