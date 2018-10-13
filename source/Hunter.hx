package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.util.*;

class Hunter extends Enemy
{
    public static inline var MAX_VELOCITY = 80;
    public static inline var JUMP_CHANCE = 3;
    public static inline var JUMP_STRENGTH = 200;

    private var isOnGround:Bool;

    public function new(x:Int, y:Int, player:Player) {
        super(x, y, player);
        loadGraphic('assets/images/hunter.png', true, 12, 14);
        animation.add('idle', [0]);
        animation.add('chasing', [0, 1, 2], 10);
        animation.play('idle');
        health = 6;
        isOnGround = false;
        placement = FlxObject.FLOOR;
    }

    override public function movement()
    {
        isOnGround = isTouching(FlxObject.FLOOR);
        if(isOnGround) {
            if (x < player.x) {
                velocity.x = MAX_VELOCITY;
            }
            else {
                velocity.x = -MAX_VELOCITY;
            }
        }
        if(isOnGround) {
            velocity.y = 0;
        }
        else {
            velocity.y += Player.GRAVITY;
        }
        if(isOnGround && FlxG.random.bool(JUMP_CHANCE)) {
            velocity.y = -(JUMP_STRENGTH + 200 * Math.random());
        }
        if(isActive) {
            animation.play('chasing');
        }
        else {
            animation.play('idle');
        }
    }
}

