package;

import flixel.*;
import flixel.effects.*;
import flixel.group.*;
import flixel.math.*;
import flixel.system.*;
import flixel.util.*;

class Enemy extends FlxSprite
{
    static public var all:FlxGroup = new FlxGroup();

    public var isActive:Bool;
    private var player:Player;
    private var startLocation:FlxPoint;

    public function new(x:Int, y:Int, player:Player) {
        super(x, y);
        this.player = player;
        all.add(this);
        isActive = false;
        startLocation = new FlxPoint(x, y);
    }

    public function movement() {
        // Overridden in child classes
    }

    override public function update(elapsed:Float)
    {
        if(isActive) {
            movement();
        }
        else {
            acceleration.x = 0;
            acceleration.y = 0;
            velocity.x = 0;
            velocity.y = 0;
            setPosition(startLocation.x, startLocation.y);
        }
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
        else {
            FlxFlicker.flicker(this, 0.25);
        }
    }
}
