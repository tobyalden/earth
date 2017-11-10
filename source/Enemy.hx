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
    private var canFly:Bool;
    private var player:Player;
    private var startLocation:FlxPoint;

    public function new(x:Int, y:Int, player:Player) {
        super(x, y);
        this.player = player;
        all.add(this);
        canFly = false;
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
            velocity = new FlxPoint(0, 0);
            acceleration = new FlxPoint(0, 0);
            resetPosition();
        }
        super.update(elapsed);
    }

    override public function kill() {
        FlxG.state.add(new Explosion(this));
        super.kill();
    }

    public function takeHit(damage:Int) {
        health -= damage;
        if(health <= 0) {
            kill();
        }
        else {
            FlxFlicker.flicker(this, 0.25);
        }
    }

    public function resetPosition(newStartLocation:FlxPoint=null) {
        if(newStartLocation != null) {
            startLocation = newStartLocation;
        }
        setPosition(startLocation.x, startLocation.y);
    }

    public function startsOnGround() {
        return !canFly;
    }
}
