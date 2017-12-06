package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.util.*;

class Guardian extends Enemy
{
    public static inline var JUMP_POWER_X = 150;
    public static inline var JUMP_POWER_Y = 150;
    public static inline var TIME_BETWEEN_SHOTS = 2;
    public static inline var SHOT_SPEED = 200;
    public static inline var SHOT_SPREAD = 25;

    private var isOnGround:Bool;
    private var shootTimer:FlxTimer;

    public function new(x:Int, y:Int, player:Player) {
        super(x, y, player);
        loadGraphic('assets/images/guardian.png', true, 16, 16);
        animation.add('red', [0]);
        animation.add('green', [1]);
        animation.add('off', [2]);
        animation.play('off');
        shootTimer = new FlxTimer();
        health = 5;
        placement = FlxObject.FLOOR;
    }

    override public function update(elapsed:Float)
    {
        if(shootTimer.progress < 0.1) {
            animation.play('red');
        }
        if(isActive) {
            animation.play('green');
        }
        else {
            animation.play('off');
        }
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

    override public function activate() {
        if(!isActive) {
            shootTimer.start(TIME_BETWEEN_SHOTS, shoot, 0);
        }
        super.activate();
    }

    override public function deactivate() {
        if(isActive) {
            shootTimer.cancel();
        }
        super.deactivate();
    }

    override public function kill() {
        super.kill();
        shootTimer.cancel();
    }
}
