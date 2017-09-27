package;

import flixel.*;
import flixel.math.*;
import flixel.util.*;

class Option extends FlxSprite
{
    public static inline var HOVER_DISTANCE = 20;
    public static inline var HANG_DISTANCE = 5;

    public static inline var ACCELERATION = 20000;
    public static inline var MAX_SPEED = 120000;

    public static inline var SHOT_COOLDOWN = 0.25;

    private var player:Player;
    private var destination:FlxPoint;
    private var shootTimer:FlxTimer;

    public function new(player:Player)
    {
        super(player.x, player.y);
        loadGraphic('assets/images/option.png');
        this.player = player;
        destination = new FlxPoint(
            player.x + HOVER_DISTANCE, player.y - HOVER_DISTANCE
        );
        shootTimer = new FlxTimer();
        shootTimer.loops = 1;
    }

    override public function update(elapsed:Float)
    {
        setDestination();
        move();
        if(Controls.checkPressed('shoot')) {
            shoot();
        }
        super.update(elapsed);
    }

    private function setDestination()
    {
        var hoverDistance = HOVER_DISTANCE;
        solid = !player.isHangingOnOption();
        if(player.isHangingOnOption()) {
            hoverDistance = HANG_DISTANCE;
        }
        destination.x = player.x + player.width/2 - width/2;
        if(player.facing == FlxObject.LEFT) {
            destination.x += hoverDistance;
        }
        else {
            destination.x -= hoverDistance;
        }
        if(Controls.checkPressed('shoot') && !player.isHangingOnOption()) {
            if(Controls.checkPressed('down')) {
                destination.y = player.y - hoverDistance * 2;
            }
            else if(Controls.checkPressed('up')) {
                destination.y = player.y - hoverDistance;
                destination.x = player.x + player.width/2 - width/2;
            }
            else {
                destination.y = player.y + player.height/2 - height/2;
            }
        }
        else {
            destination.y = player.y - hoverDistance;
        }
    }

    private function move()
    {
        if(
            player.isHangingOnOption()
            && FlxMath.distanceToPoint(this, destination) < 30
        ) {
            x = (x + destination.x * 2)/3;
            y = (y + destination.y * 2)/3;
            velocity.set(0, 0);
            acceleration.set(0, 0);
        }
        else if(FlxMath.distanceToPoint(this, destination) < 3) {
            FlxVelocity.accelerateTowardsPoint(
                this, destination, ACCELERATION/8, MAX_SPEED
            );
        }
        else if(FlxMath.distanceToPoint(this, destination) < 10) {
            FlxVelocity.accelerateTowardsPoint(
                this, destination, ACCELERATION/2, MAX_SPEED
            );
        }
        else if(player.isHangingOnOption() && FlxMath.distanceToPoint(this, destination) > 30) {
            FlxVelocity.accelerateTowardsPoint(
                this, destination, ACCELERATION*4, MAX_SPEED
            );
        }
        else if(player.isHangingOnOption()) {
            FlxVelocity.accelerateTowardsPoint(
                this, destination, ACCELERATION*2, MAX_SPEED
            );
        }
        else {
            FlxVelocity.accelerateTowardsPoint(
                this, destination, ACCELERATION, MAX_SPEED
            );
        }
    }

    private function shoot()
    {
        if(!shootTimer.active && !player.isHangingOnOption()) {
            shootTimer.reset(SHOT_COOLDOWN);
            var bulletVelocity = new FlxPoint(Bullet.SPEED, 0);
            if (player.facing == FlxObject.LEFT) {
                bulletVelocity.x = -Bullet.SPEED;
            }
            if(Controls.checkPressed('down')) {
                bulletVelocity.y = Bullet.SPEED;
            }
            if(Controls.checkPressed('up')) {
                bulletVelocity.y = -Bullet.SPEED;
            }
            var bullet = new Bullet(
                Std.int(x + width/2), Std.int(y + height/2), bulletVelocity
            );
            FlxG.state.add(bullet);
        }
    }

}
