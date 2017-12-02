package;

import flixel.*;
import flixel.group.*;
import flixel.util.*;

class TrapExplosion extends FlxSprite
{
    public static inline var SIZE = 96;
    public static inline var DAMAGE = 100;

    static public var all:FlxGroup = new FlxGroup();

    public function new(source:FlxSprite) {
        super(
            source.x + source.width/2 - SIZE/2,
            source.y + source.height/2 - SIZE/2
        );
        loadGraphic('assets/images/bigexplosion.png', true, SIZE, SIZE);
        animation.add('explode', [0, 1, 2, 3, 4, 5, 6, 7], 50, false);
        animation.play('explode');
        width = SIZE/2;
        height = SIZE/2;
        offset.x = SIZE/4;
        offset.y = SIZE/4;
        x += SIZE/4;
        y += SIZE/4;
        all.add(this);
    }
    
    override public function update(elapsed:Float)
    {
        if(animation.finished) {
            destroy();
            return;
        }
        super.update(elapsed);
    }

}

