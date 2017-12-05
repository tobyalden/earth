package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.util.*;

class Guardian extends Enemy
{
    public static inline var JUMP_POWER_X = 150;
    public static inline var JUMP_POWER_Y = 150;
    public static inline var TIME_BETWEEN_SHOTS = 3;
    public static inline var SHOT_SPEED = 200;
    public static inline var SHOT_SPREAD = 25;

    private var isOnGround:Bool;
    private var shootTimer:FlxTimer;

    public function new(x:Int, y:Int, player:Player) {
        super(x, y, player);
        loadGraphic('assets/images/guardian.png', true, 16, 16);
        animation.add('idle', [0]);
        animation.play('idle');
        shootTimer = new FlxTimer();
        shootTimer.start(TIME_BETWEEN_SHOTS, shoot, 0);
        health = 3;
        placement = FlxObject.FLOOR;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    private function shoot(_:FlxTimer) {
        if(!isActive || !isOnScreen()) {
            return;
        }
        var angle = FlxAngle.angleBetween(this, player, true);
        for(i in 0...3) {
            var spreadAngle = angle + new FlxRandom().float(
                -SHOT_SPREAD, SHOT_SPREAD
            );
            var bulletVelocity = FlxVelocity.velocityFromAngle(
                spreadAngle, SHOT_SPEED
            );
            var bullet = new EnemyBullet(
                Std.int(x + 8), Std.int(y + 8), bulletVelocity
            );
            FlxG.state.add(bullet);
        }
        //shootSfx.play();
    }

    override public function kill() {
        super.kill();
        shootTimer.cancel();
    }
}
