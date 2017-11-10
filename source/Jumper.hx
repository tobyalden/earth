package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.util.*;

class Jumper extends Enemy
{
    public static inline var JUMP_POWER_X = 100;
    public static inline var JUMP_POWER_Y = 100;
    public static inline var STARTING_HEALTH = 1;
    public static inline var TIME_BETWEEN_JUMPS = 1;

    private var isOnGround:Bool;
    private var jumpCooldown:FlxTimer;

    public function new(x:Int, y:Int, player:Player) {
        super(x, y, player);
        loadGraphic('assets/images/jumper.png', true, 16, 16);
        animation.add('idle', [0]);
        animation.add('jump', [1, 2], 1, false);
        animation.play('idle');
        jumpCooldown = new FlxTimer();
        jumpCooldown.start(TIME_BETWEEN_JUMPS, jump, 0);
        isOnGround = false;
        health = STARTING_HEALTH;
    }

    override public function update(elapsed:Float)
    {
        // TODO: Don't reset position if jumper jumps offscreen
        // TODO: Clean up / fix animation
        isOnGround = isTouching(FlxObject.DOWN);
        if(isOnGround) {
            velocity.x = 0;
            velocity.y = 0;
        }
        else {
            velocity.y += Player.GRAVITY;
        }
        super.update(elapsed);
    }

    private function jump(_:FlxTimer) {
        y -= 1;
        velocity.y = -JUMP_POWER_Y;
        if (x < player.x) {
            velocity.x = JUMP_POWER_X;
        }
        else {
            velocity.x = -JUMP_POWER_X;
        }
        animation.play('jump');
    }
}

