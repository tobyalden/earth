package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.util.*;
import flixel.system.*;

class Gunner extends Enemy
{
    public static inline var MAX_VELOCITY = 30;
    public static inline var SHOOT_CHANCE = 1;

    public static inline var NUMBER_OF_SHOTS = 3;
    public static inline var SHOT_SPEED = 150;

    private var isOnGround:Bool;
    private var shootSfx:FlxSound;
    private var isShooting:Bool;
    private var shotTimer:FlxTimer;
    private var switchStateTimer:FlxTimer;

    public function new(x:Int, y:Int, player:Player) {
        super(x, y, player);
        loadGraphic('assets/images/gunner.png', true, 16, 21);
        animation.add('idle', [3]);
        animation.add('shooting', [4]);
        animation.add('chasing', [0, 1, 2], 10);
        animation.play('idle');
        health = 3;
        isOnGround = false;
        placement = FlxObject.FLOOR;
        setFacingFlip(FlxObject.LEFT, true, false);
        setFacingFlip(FlxObject.RIGHT, false, false);
        isShooting = false;
        shotTimer = new FlxTimer();
        shotTimer.start(0.6, shoot, 0);
        switchStateTimer = new FlxTimer();
        new FlxTimer().start(
            Math.random() * 3,
            function(_:FlxTimer) {
                switchStateTimer.start(3, function(_:FlxTimer) {
                    isShooting = !isShooting;
                }, 0);
            },
            1
        );
        shootSfx = FlxG.sound.load('assets/sounds/enemyshoot.ogg');
        shootSfx.volume = 0.24;
    }

    override public function movement()
    {
        isOnGround = isTouching(FlxObject.FLOOR);
        if(isOnGround) {
            if(isShooting) {
                velocity.x = 0;
                if (x < player.x) {
                    facing = FlxObject.RIGHT;
                }
                else {
                    facing = FlxObject.LEFT;
                }
            }
            else {
                if (x < player.x) {
                    facing = FlxObject.RIGHT;
                    velocity.x = MAX_VELOCITY;
                }
                else {
                    facing = FlxObject.LEFT;
                    velocity.x = -MAX_VELOCITY;
                }
            }
        }
        if(isOnGround) {
            velocity.y = 0;
        }
        else {
            velocity.y += Player.GRAVITY;
        }
        if(!isActive) {
            animation.play('idle');
        }
        else if(isShooting) {
            animation.play('shooting');
        }
        else {
            animation.play('chasing');
        }
    }

    override public function kill() {
        shotTimer.cancel();
        super.kill();
    }

    public function shoot(_:FlxTimer) {
        if(!isActive || !isOnScreen() || !isShooting) {
            return;
        }
        var bulletVelocity = new FlxPoint(0, 0);
        var shotAngle = FlxAngle.angleBetween(this, player, true);
        var bulletVelocity = FlxVelocity.velocityFromAngle(
            shotAngle, SHOT_SPEED
        );
        bulletVelocity.y -= 70;
        var bullet = new EnemyBullet(
            Std.int(x + 8), Std.int(y + 8), bulletVelocity
        );
        FlxG.state.add(bullet);
        shootSfx.play();
    }
}
