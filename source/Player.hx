package;

import flixel.*;
import flixel.math.*;
import flixel.system.*;
import flixel.util.*;

class Player extends FlxSprite
{
    public static inline var SPEED = 150;
    public static inline var JUMP_POWER = 330;
    public static inline var BULLET_SPREAD = 45;
    public static inline var BULLET_KICKBACK_UP = 260;
    public static inline var BULLET_KICKBACK_SIDE = 200;
    public static inline var JUMP_CANCEL_POWER = 100;
    public static inline var GRAVITY = 12;
    public static inline var LIFT_ACCEL = 800;
    public static inline var AIR_ACCEL = 1500;
    public static inline var GROUND_ACCEL = 2000;
    public static inline var GROUND_DRAG = 2000;
    public static inline var TERMINAL_VELOCITY = 300;
    public static inline var OPTION_LIFT = 10;
    public static inline var MAX_LIFT_SPEED = 150;
    public static inline var SHOT_COOLDOWN = 0.5;

    private var isOnGround:Bool;
    private var isLookingUp:Bool;
    private var isLookingDown:Bool;
    private var hangingOnOption:Bool;

    private var runSfx:FlxSound;
    private var deathSfx:FlxSound;
    private var jumpSfx:FlxSound;
    private var landSfx:FlxSound;

    public function new(x:Int, y:Int)
    {
        super(x, y);
        loadGraphic('assets/images/player.png', true, 16, 24);

        width = 5;
        height = 19;
        offset.x = 6;
        offset.y = 5;

        setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);
        animation.add('idle', [0]);
        animation.add('run', [1, 2, 3]);
        animation.add('jump', [4]);
        animation.add('up', [5]);
        animation.add('run_up', [6, 7, 8]);
        animation.add('jump_up', [9]);
        animation.add('jump_down', [10]);
        animation.play('idle');

        isOnGround = false;
        isLookingUp = false;
        isLookingDown = false;
        hangingOnOption = false;

        runSfx = FlxG.sound.load('assets/sounds/runloop.wav');
        deathSfx = FlxG.sound.load('assets/sounds/death.wav');
        jumpSfx = FlxG.sound.load('assets/sounds/jump.wav');
        landSfx = FlxG.sound.load('assets/sounds/land.wav');
        runSfx.looped = true;
    }

    override public function update(elapsed:Float)
    {
        if(justTouched(FlxObject.FLOOR)) {
            landSfx.play();
        }
        isOnGround = isTouching(FlxObject.DOWN);
        isLookingUp = Controls.checkPressed('up');
        isLookingDown = Controls.checkPressed('down');
        move();
        animate();
        sound();
        super.update(elapsed);
    }

    override public function kill() {
        deathSfx.play();
        FlxG.state.add(new Explosion(this));
        runSfx.stop();
        super.kill();
    }

    private function move()
    {
        if(isOnGround) {
            hangingOnOption = false;
        }
        if(Controls.checkPressed('left')) {
            if(isOnGround) {
                acceleration.x = -GROUND_ACCEL;
            }
            else if(hangingOnOption) {
                acceleration.x = -LIFT_ACCEL;
            }
            else {
                acceleration.x = -AIR_ACCEL;
            }
            facing = FlxObject.LEFT;
        }
        else if(Controls.checkPressed('right')) {
            if(isOnGround) {
                acceleration.x = GROUND_ACCEL;
            }
            else if(hangingOnOption) {
                acceleration.x = LIFT_ACCEL;
            }
            else {
                acceleration.x = AIR_ACCEL;
            }
            facing = FlxObject.RIGHT;
        }
        else {
            acceleration.x = 0;
            if(isOnGround) {
                drag.x = GROUND_DRAG;
            }
            else if(hangingOnOption) {
                drag.x = LIFT_ACCEL;
            }
            else {
                drag.x = AIR_ACCEL/2;
            }
        }

        if(Controls.checkJustPressed('jump')) {
            if(isOnGround) {
                velocity.y = -JUMP_POWER;
                jumpSfx.play();
            }
            else {
                hangingOnOption = true;
            }
        }

        if(Controls.checkJustReleased('jump') && !isOnGround) {
            if(hangingOnOption) {
                hangingOnOption = false;
            }
            else {
                velocity.y = Math.max(velocity.y, -JUMP_CANCEL_POWER);
            }
        }

        velocity.x = Math.min(velocity.x, SPEED);
        velocity.x = Math.max(velocity.x, -SPEED);
        if(hangingOnOption) {
            velocity.y = Math.max(
                velocity.y - OPTION_LIFT, -MAX_LIFT_SPEED
            );
        }
        else {
            velocity.y = Math.min(velocity.y + GRAVITY, TERMINAL_VELOCITY);
        }
    }

    private function animate()
    {
        if(!isOnGround) {
            if (isLookingDown) {
                animation.play('jump_down');
            }
            else if(isLookingUp) {
                animation.play('jump_up');
            }
            else {
                animation.play('jump');
            }
        }
        else if(velocity.x != 0) {
            if(isLookingUp) {
                animation.play('run_up');
            }
            else {
                animation.play('run');
            }
        }
        else {
            if(isLookingUp) {
                animation.play('up');
            }
            else {
                animation.play('idle');
            }
        }
    }

    private function sound()
    {
        if(animation.name == 'run') {
            runSfx.play();
        }
        else {
            runSfx.stop();
        }
    }

    public function isHangingOnOption() {
        return hangingOnOption;
    }

}
