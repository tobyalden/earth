package;

import flixel.*;
import flixel.effects.*;
import flixel.group.*;
import flixel.math.*;
import flixel.system.*;
import flixel.util.*;

class Enemy extends FlxSprite
{
    public static inline var ACTIVE_RADIUS = 150;
    static public var all:FlxGroup = new FlxGroup();

    public var isActive:Bool;
    public var ghost:Bool;
    private var canFly:Bool;
    private var player:Player;
    private var startLocation:FlxPoint;
    private var placement:Int;

    private var hitSfx:FlxSound;
    private var deathSfx:FlxSound;

    public function new(x:Int, y:Int, player:Player) {
        super(x, y);
        this.player = player;
        all.add(this);
        canFly = false;
        isActive = false;
        placement = FlxObject.NONE;
        ghost = false;
        hitSfx = FlxG.sound.load('assets/sounds/enemyhit.ogg');
        deathSfx = FlxG.sound.load('assets/sounds/enemydeath.ogg');
    }

    public function movement() {
        // Overridden in child classes
    }

    override public function setPosition(newX:Float = 0, newY:Float = 0):Void {
        super.setPosition(newX, newY);
        startLocation = new FlxPoint(x, y);
    }

    override public function update(elapsed:Float)
    {
        // TODO: Prevent flying enemies from leaving the screen they're on
        if(isActive) {
            movement();
        }
        else {
            velocity.x = 0;
            if(canFly) {
                velocity.y = 0;
            }
            acceleration = new FlxPoint(0, 0);
        }
        super.update(elapsed);
    }

    override public function kill() {
        all.remove(this);
        FlxG.state.add(new Explosion(this));
        super.kill();
    }

    public function killQuietly() {
        all.remove(this);
        super.kill();
    }

    public function activate() {
        isActive = true;
    }

    public function deactivate() {
        isActive = false;
    }

    public function takeHit(damage:Int) {
        health -= damage;
        if(health <= 0) {
            deathSfx.play();
            kill();
        }
        else {
            hitSfx.play();
            FlxFlicker.flicker(this, 0.25);
        }
    }

    public function resetPosition(newStartLocation:FlxPoint=null) {
        if(newStartLocation != null) {
            startLocation = newStartLocation;
        }
        setPosition(startLocation.x, startLocation.y);
    }

    public function getPlacement() {
        return placement;
    }

    public function isGhost() {
        return ghost;
    }
}
