package;

import flixel.*;
import flixel.effects.*;
import flixel.math.*;
import flixel.system.*;
import flixel.util.*;

class Player extends FlxSprite
{
    public static inline var SPEED = 150;
    public static inline var JUMP_POWER = 330;
    public static inline var JUMP_CANCEL_POWER = 100;
    public static inline var JUMP_GRACE_PERIOD = 0.1;
    public static inline var GRAVITY = 12;
    public static inline var AIR_ACCEL = 1500;
    public static inline var GROUND_ACCEL = 2000;
    public static inline var GROUND_DRAG = 2000;
    public static inline var TERMINAL_VELOCITY = 300;
    public static inline var PUSHBACK_SPEED = 200;
    public static inline var PUSHBACK_DURATION = 0.5;
    public static inline var SHOT_COOLDOWN = 0.5;
    public static inline var SHOT_DAMAGE = 1;

    private var isOnGround:Bool;
    private var wasOnGround:FlxTimer;
    private var isLookingUp:Bool;
    private var isLookingDown:Bool;

    private var runSfx:FlxSound;
    private var deathSfx:FlxSound;
    private var jumpSfx:FlxSound;
    private var landSfx:FlxSound;

    private var lastCheckpoint:FlxPoint;

    private var pushback:FlxTimer;

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
        wasOnGround = new FlxTimer();
        isLookingUp = false;
        isLookingDown = false;

        runSfx = FlxG.sound.load('assets/sounds/runloop.wav');
        deathSfx = FlxG.sound.load('assets/sounds/death.wav');
        jumpSfx = FlxG.sound.load('assets/sounds/jump.wav');
        landSfx = FlxG.sound.load('assets/sounds/land.wav');
        runSfx.looped = true;

        lastCheckpoint = new FlxPoint(x, y);

        pushback = new FlxTimer();
    }

    override public function update(elapsed:Float)
    {
        if(justTouched(FlxObject.FLOOR)) {
            landSfx.play();
        }
        if(!isTouching(FlxObject.DOWN) && isOnGround) {
            wasOnGround.start(JUMP_GRACE_PERIOD);
        }
        isOnGround = isTouching(FlxObject.DOWN);
        isLookingUp = Controls.checkPressed('up');
        isLookingDown = Controls.checkPressed('down');
        move();
        animate();
        sound();
        super.update(elapsed);
    }

    public function pushBack(direction:Int) {
        pushback.start(PUSHBACK_DURATION);
        if(direction == FlxObject.LEFT) {
            velocity.x = -PUSHBACK_SPEED;
        }
        else if(direction == FlxObject.RIGHT) {
            velocity.x = PUSHBACK_SPEED;
        }
    }


    private function move()
    {
        if(Controls.checkPressed('left')) {
            if(isOnGround) {
                acceleration.x = -GROUND_ACCEL;
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
            else {
                drag.x = AIR_ACCEL/2;
            }
        }

        if(Controls.checkJustPressed('jump')) {
            if(isOnGround || wasOnGround.active) {
                velocity.y = -JUMP_POWER;
                jumpSfx.play();
                isOnGround = false;
                wasOnGround.cancel();
            }
        }

        if(Controls.checkJustReleased('jump') && !isOnGround) {
            velocity.y = Math.max(velocity.y, -JUMP_CANCEL_POWER);
        }

        var maxSpeed = SPEED;
        if(pushback.active) {
            maxSpeed = PUSHBACK_SPEED;
        }
        velocity.x = Math.min(velocity.x, maxSpeed);
        velocity.x = Math.max(velocity.x, -maxSpeed);
        velocity.y = Math.min(velocity.y + GRAVITY, TERMINAL_VELOCITY);
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

    public function takeHit() {
        die();
    }

    private function die() {
        FlxG.state.add(new Explosion(this));
        deathSfx.play();
        runSfx.stop();
        kill();
        new FlxTimer().start(2, respawn);
    }

    private function respawn(_:FlxTimer) {
        x = lastCheckpoint.x;
        y = lastCheckpoint.y;
        revive();
    }
}
