package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.util.*;

class Flopper extends Enemy
{
    public static inline var JUMP_POWER_X = 60;
    public static inline var JUMP_POWER_Y = 160;
    public static inline var TIME_BETWEEN_JUMPS = 2;

    private var isOnCeiling:Bool;
    private var jumpCooldown:FlxTimer;

    public function new(x:Int, y:Int, player:Player) {
        super(x, y, player);
        loadGraphic('assets/images/flopper.png', true, 16, 16);
        animation.add('idle', [0]);
        animation.add('jump', [1, 2], 1, false);
        animation.play('idle');
        jumpCooldown = new FlxTimer();
        jumpCooldown.start(TIME_BETWEEN_JUMPS, jump, 0);
        isOnCeiling = false;
        health = 4;
    }

    override public function update(elapsed:Float)
    {
        if(justTouched(FlxObject.UP)) {
            isOnCeiling = true;
        }
        if(isOnCeiling) {
            velocity.x = 0;
            velocity.y = 0;
        }
        else {
            velocity.y -= Player.GRAVITY/3;
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
        if(!isActive || !isOnCeiling) {
            return;
        }
        isOnCeiling = false;
        velocity.y = JUMP_POWER_Y;
        if (x < player.x) {
            velocity.x = JUMP_POWER_X;
        }
        else {
            velocity.x = -JUMP_POWER_X;
        }
    }
}

