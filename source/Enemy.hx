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

    override public function update(elapsed:Float)
    {
        movement();
        super.update(elapsed);
    }

    public function movement() { }

    override public function kill() {
        FlxG.state.add(new Explosion(this));
        super.kill();
    }

}
