package;

import flixel.*;
import flixel.math.*;
import flixel.util.*;

class Option extends FlxSprite
{
    public static inline var HOVER_DISTANCE_X = 20;
    public static inline var HOVER_DISTANCE_Y = 20;

    public static inline var NEAR_ACCELERATION = 10000;
    public static inline var FAR_ACCELERATION = 20000;
    public static inline var MAX_SPEED = 120000;

    private var player:Player;
    private var destination:FlxPoint;

    public function new(player:Player)
    {
        super(player.x, player.y);
        loadGraphic('assets/images/option.png');
        this.player = player;
        destination = new FlxPoint(
            player.x + HOVER_DISTANCE_X, player.y - HOVER_DISTANCE_Y
        );
    }

    override public function update(elapsed:Float)
    {
        setDestination();
        move();
        if(Controls.checkJustPressed('shoot')) {
            shoot();
        }
        super.update(elapsed);
    }

    private function setDestination()
    {
        if(player.facing == FlxObject.LEFT) {
            destination.x = player.x + player.width/2 + HOVER_DISTANCE_X;
        }
        else {
            destination.x = player.x + player.width/2 - HOVER_DISTANCE_Y;
        }
        destination.y = player.y - HOVER_DISTANCE_Y;
    }

    private function move()
    {
        if(FlxMath.distanceToPoint(this, destination) < 3) {
            FlxVelocity.accelerateTowardsPoint(
                this, destination, NEAR_ACCELERATION/4, MAX_SPEED
            );
        }
        else if(FlxMath.distanceToPoint(this, destination) < 10) {
            FlxVelocity.accelerateTowardsPoint(
                this, destination, NEAR_ACCELERATION, MAX_SPEED
            );
        }
        else {
            FlxVelocity.accelerateTowardsPoint(
                this, destination, FAR_ACCELERATION, MAX_SPEED
            );
        }
    }

    private function shoot()
    {
        var bulletVelocity = new FlxPoint(Bullet.SPEED, 0);
        if (player.facing == FlxObject.LEFT) {
            bulletVelocity.x = -Bullet.SPEED;
        }
        var bullet = new Bullet(
            Std.int(x + width/2), Std.int(y + height/2), bulletVelocity
        );
        FlxG.state.add(bullet);
    }

}
