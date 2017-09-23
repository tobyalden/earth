package;

import flixel.*;
import flixel.util.*;

class Explosion extends FlxSprite
{
    public static inline var SIZE = 32;

    public function new(source:FlxSprite) {
        super(
            source.x + source.width/2 - SIZE/2,
            source.y + source.height/2 - SIZE/2
        );
        loadGraphic('assets/images/explosion.png', true, SIZE, SIZE);
        animation.add('explode', [0, 1], 10, false);
        animation.play('explode');
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
