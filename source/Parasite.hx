package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.util.*;

class Parasite extends Enemy
{
    public static inline var ACCELERATION = 5000;
    public static inline var MAX_VELOCITY = 40;

    public function new(x:Int, y:Int, player:Player) {
        super(x, y, player);
        this.player = player;
        loadGraphic('assets/images/parasite.png', true, 16, 16);
        animation.add('idle', [0, 1, 2, 3, 4], 10);
        animation.play('idle');
        health = 5;
    }

    override public function movement()
    {
        FlxVelocity.accelerateTowardsObject(
            this, player, ACCELERATION, MAX_VELOCITY
        );
    }
}
