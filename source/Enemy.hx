package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.system.*;
import flixel.util.*;

class Enemy extends FlxSprite
{
    static public var all:FlxGroup = new FlxGroup();

    private var player:Player;

    public function new(x:Int, y:Int, player:Player) {
        super(x, y);
        all.add(this);
    }

    public function movement() {
        // Overridden in child classes
    }

    override public function update(elapsed:Float)
    {
        movement();
        super.update(elapsed);
    }

    override public function kill() {
        FlxG.state.add(new Explosion(this));
        super.kill();
    }

    public function takeHit() {
        health -= 1;
        if(health <= 0) {
            kill();
        }
    }
}
