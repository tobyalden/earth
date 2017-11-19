package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.system.*;
import flixel.util.*;

class Fleer extends Seer
{
    public static inline var ACCELERATION = 60;
    public static inline var SPEED = 40;
    public static inline var SHOT_SPEED = 120;


    public function new(x:Int, y:Int, player:Player) {
        super(x, y, player);
        loadGraphic('assets/images/fleer.png', true, 16, 16);
        animation.add('right', [0]);
        animation.add('down', [1]);
        animation.add('left', [2]);
        animation.add('up', [3]);
        shootTimer.start(0.6, shoot, 0);
        shotSpeed = SHOT_SPEED;
        health = 2;
    }

    override public function movement() {
        maxVelocity = new FlxPoint(SPEED, SPEED);
        if(x > player.x) {
            acceleration.x = ACCELERATION;
        }
        else if(x < player.x) {
            acceleration.x = -ACCELERATION;
        }
        if(y > player.y) {
            acceleration.y = ACCELERATION;
        }
        else if(y < player.y) {
            acceleration.y = -ACCELERATION;
        }
        animation.play(myFacing);
    }
}
