package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.util.*;

class Jumper extends Enemy
{
    public static inline var JUMP_POWER_X = 100;
    public static inline var JUMP_POWER_Y = 100;
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
        health = 1;
        placement = FlxObject.FLOOR;
    }

    override public function update(elapsed:Float)
    {
        if(justTouched(FlxObject.FLOOR)) {
            isOnGround = true;
        }
        if(isOnGround) {
            velocity.x = 0;
            velocity.y = 0;
        }
        else {
            velocity.y += Player.GRAVITY;
        }
        if(isActive) {
            animation.play('jump');
        }
        else {
            animation.play('idle');
        }
        super.update(elapsed);
    }

    private function jump(_:FlxTimer) {
        if(!isActive || !isOnGround) {
            return;
        }
        isOnGround = false;
        velocity.y = -JUMP_POWER_Y;
        if (x < player.x) {
            velocity.x = JUMP_POWER_X;
        }
        else {
            velocity.x = -JUMP_POWER_X;
        }
    }
}

