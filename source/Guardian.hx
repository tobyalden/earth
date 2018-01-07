package;

import flixel.*;
import flixel.effects.*;
import flixel.group.*;
import flixel.math.*;
import flixel.system.*;
import flixel.util.*;

class Guardian extends Enemy
{
    public static inline var JUMP_POWER_X = 150;
    public static inline var JUMP_POWER_Y = 150;
    public static inline var TIME_BETWEEN_SHOTS = 2.5;
    public static inline var SHOT_SPEED = 200;
    public static inline var SHOT_SPREAD = 25;

    private var isOnGround:Bool;
    private var shootTimer:FlxTimer;
    private var shotAngle:Float;
    private var shootSfx:FlxSound;
    private var lockOnSfx:FlxSound;

    public function new(x:Int, y:Int, player:Player) {
        super(x, y, player);
        loadGraphic('assets/images/guardian.png', true, 16, 16);
        shootSfx = FlxG.sound.load('assets/sounds/tripleshot.wav');
        lockOnSfx = FlxG.sound.load('assets/sounds/lockon.wav');
        shootSfx.volume = 0.28;
        animation.add('red', [0]);
        animation.add('green', [1]);
        animation.add('off', [2]);
        animation.add('broken', [3]);
        animation.play('off');
        shootTimer = new FlxTimer();
        health = 5;
        placement = FlxObject.FLOOR;
        damageOnTouch = false;
        immovable = true;
    }

    override public function update(elapsed:Float)
    {
        if(health <= 0) {
            animation.play('broken');
        }
        else if(!isActive) {
            animation.play('off');
        }
        else if(shootTimer.progress > 0.80) {
            if(animation.name == 'green') {
                setTarget();
                lockOnSfx.play();
                animation.play('red');
            }
        }
        else {
            animation.play('green');
        }
        super.update(elapsed);
    }

    private function setTarget() {
        shotAngle = FlxAngle.angleBetween(this, player, true);
    }

    override public function takeHit(damage:Int) {
        health -= damage;
        if(health <= 0) {
            deathSfx.play();
        }
        else {
            hitSfx.play();
            FlxFlicker.flicker(this, 0.25);
        }
    }

    private function shoot(_:FlxTimer) {
        if(!isActive || !isOnScreen() || health <= 0) {
            return;
        }
        for(i in 0...3) {
            var spreadAngle = shotAngle + new FlxRandom().float(
                -SHOT_SPREAD, SHOT_SPREAD
            );
            var bulletVelocity = FlxVelocity.velocityFromAngle(
                spreadAngle, SHOT_SPEED
            );
            var bullet = new EnemyBullet(
                Std.int(x + 8), Std.int(y + 8), bulletVelocity
            );
            FlxG.state.add(bullet);
        }
        shootSfx.play();
    }

    override public function activate() {
        if(!isActive) {
            shootTimer.start(TIME_BETWEEN_SHOTS, shoot, 0);
        }
        super.activate();
    }

    override public function deactivate() {
        if(isActive) {
            shootTimer.cancel();
        }
        super.deactivate();
    }

    override public function kill() {
        super.kill();
        shootTimer.cancel();
    }
}
