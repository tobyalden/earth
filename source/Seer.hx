package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.system.*;
import flixel.util.*;

class Seer extends Enemy
{
    public static inline var SHOT_SPEED = 200;

    private var myFacing:String;
    private var shootTimer:FlxTimer;
    private var shootSfx:FlxSound;

    public function new(x:Int, y:Int, player:Player) {
        super(x, y, player);
        loadGraphic('assets/images/seer.png', true, 16, 16);
        animation.add('right', [0]);
        animation.add('down', [1]);
        animation.add('left', [2]);
        animation.add('up', [3]);
        health = 2;
        shootTimer = new FlxTimer();
        shootTimer.start(1, shoot, 0);
        shootSfx = FlxG.sound.load('assets/sounds/enemyshoot.ogg');
        shootSfx.volume = 0.24;
    }

    override public function movement() {
        animation.play(myFacing);
    }

    override public function kill() {
        super.kill();
        shootTimer.cancel();
    }

    public function shoot(_:FlxTimer) {
        if(!isActive || !isOnScreen()) {
            return;
        }
        var bulletVelocity = new FlxPoint(0, 0);
        if(
            FlxAngle.angleBetween(this, player, true) < -120
            || FlxAngle.angleBetween(this, player, true) > 120
        ) {
            myFacing = 'left';
            bulletVelocity.x = -SHOT_SPEED;
        }
        else if(FlxAngle.angleBetween(this, player, true) < -60) {
            myFacing = 'up';
            bulletVelocity.y = -SHOT_SPEED;
        }
        else if(FlxAngle.angleBetween(this, player, true) < 60) {
            myFacing = 'right';
            bulletVelocity.x = SHOT_SPEED;
        }
        else if(FlxAngle.angleBetween(this, player, true) < 120) {
            myFacing = 'down';
            bulletVelocity.y = SHOT_SPEED;
        }
        var bullet = new EnemyBullet(
            Std.int(x + 8), Std.int(y + 8), bulletVelocity
        );
        FlxG.state.add(bullet);
        if (
            Math.floor(x/FlxG.width) == Math.floor(player.x/FlxG.width)
            && Math.floor(y/FlxG.height) == Math.floor(player.y/FlxG.height)
        ) {
            shootSfx.play();
        }
    }
}
