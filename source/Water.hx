package;

import flixel.*;
import flixel.group.*;
import flixel.system.*;
import flixel.util.*;

class Water extends FlxSprite
{
    public static var all:FlxGroup = new FlxGroup();

    public function new(x:Int, y:Int, length:Int) {
        super(x, y);
        loadGraphic('assets/images/water.png', false);
        setGraphicSize(length, 16);
        updateHitbox();
        all.add(this);
    }
}

