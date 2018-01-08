package;

import flixel.*;
import flixel.group.*;
import flixel.system.*;
import flixel.util.*;

class DepthDisplay extends FlxGroup
{
    public static inline var FADE_RATE = 0.005;
    public static inline var ZOOM_RATE = 1;

    private var deco:FlxSprite;
    private var numberDisplay:FlxSprite;

    private var sfx:FlxSound;

    public function new(x:Int, y:Int, number:Int) {
        super();

        deco = new FlxSprite(x, y);
        deco.loadGraphic('assets/images/leveldeco.png', true, 320, 240);
        deco.animation.add('idle', [
            5, 6, 7, 8, 9, 10, 11, 1, 2, 3, 2, 1, 11, 10, 9, 8, 7, 6
        ], 12);
        deco.animation.play('idle');
        add(deco);

        numberDisplay = new FlxSprite(x, y);
        numberDisplay.loadGraphic('assets/images/level${number}.png');
        add(numberDisplay);

        sfx = FlxG.sound.load('assets/sounds/level${number}.wav');
        sfx.play();
    }

    override public function update(elapsed:Float) {
        deco.alpha = Math.max(0, deco.alpha -= FADE_RATE);
        numberDisplay.alpha = deco.alpha;
        numberDisplay.scale.set(
            numberDisplay.scale.x + FADE_RATE * ZOOM_RATE,
            numberDisplay.scale.y + FADE_RATE * ZOOM_RATE
        );
        super.update(elapsed);
    }
}
