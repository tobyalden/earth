package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.util.*;

class Predator extends Enemy
{
    public static inline var ACCELERATION = 80;
    public static inline var SPEED = 50;

    public function new(x:Int, y:Int, player:Player) {
        super(x, y, player);
        loadGraphic('assets/images/predator.png', true, 16, 16);
        animation.add('idle', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 10);
        health = 6;
        animation.play('idle');
    }

    override public function movement()
    {
        maxVelocity = new FlxPoint(SPEED, SPEED);
        if(x > player.x) {
            acceleration.x = -ACCELERATION;
        }
        else if(x < player.x) {
            acceleration.x = ACCELERATION;
        }
        if(y > player.y) {
            acceleration.y = -ACCELERATION;
        }
        else if(y < player.y) {
            acceleration.y = ACCELERATION;
        }
    }
}

