package;

import flixel.*;
import flixel.util.*;

class Door extends FlxSprite
{
    public function new(x:Int, y:Int) {
        super(x, y);
        loadGraphic('assets/images/door.png', true, 32, 32);
        animation.add('closed', [0]);
        animation.add('open', [1]);
        animation.play('closed');
    }

    public function open() {
        animation.play('open');
    }

    public function isOpen() {
        return animation.name == 'open';
    }
}
