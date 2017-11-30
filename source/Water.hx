package;

import flixel.*;
import flixel.system.*;
import flixel.util.*;

class Water extends FlxSprite
{
    public function new(x:Int, y:Int, length:Int) {
        super(x, y);
        loadGraphic('assets/images/water.png', false);
        setGraphicSize(length, 16);
        updateHitbox();
    }
}

