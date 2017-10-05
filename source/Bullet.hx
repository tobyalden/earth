package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.system.*;
import flixel.util.*;

class Bullet extends FlxSprite
{
    public static inline var SIZE = 4;
    public static inline var SPEED = 600;
    public static inline var GRAVITY = 3;
    //private var hitSfx:FlxSound;

    public static var all:FlxGroup = new FlxGroup();

    public function new(x:Int, y:Int, velocity:FlxPoint)
    {
        super(x - SIZE/2, y - SIZE/2);
        this.velocity = velocity;
        makeGraphic(SIZE, SIZE, FlxColor.WHITE);
        all.add(this);
        //hitSfx = FlxG.sound.load('assets/sounds/hit.wav');
        //hitSfx.volume = 0.33;
    }

    override public function update(elapsed:Float)
    {
        velocity.y += GRAVITY;
        super.update(elapsed);
    }

    override public function destroy()
    {
        FlxG.state.add(new Explosion(this));
        //hitSfx.play(true);
        all.remove(this);
        super.destroy();
    }

    public function destroyQuietly()
    {
        all.remove(this);
        super.destroy();
    }
}
