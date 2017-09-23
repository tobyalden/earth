package;

import flixel.*;
import flixel.math.*;
import flixel.system.*;
import flixel.util.*;
import flixel.input.gamepad.*;
import flixel.input.keyboard.*;


class Player extends FlxSprite
{
    public static inline var SPEED = 150;
    public static inline var JUMP_POWER = 330;
    public static inline var BULLET_SPREAD = 45;
    public static inline var BULLET_KICKBACK_UP = 260;
    public static inline var BULLET_KICKBACK_SIDE = 200;
    public static inline var JUMP_CANCEL_POWER = 100;
    public static inline var GRAVITY = 12;
    public static inline var AIR_ACCEL = 1500;
    public static inline var GROUND_ACCEL = 2000;
    public static inline var GROUND_DRAG = 2000;
    public static inline var TERMINAL_VELOCITY = 300;
    public static inline var SHOT_COOLDOWN = 0.5;
    public static inline var DEAD_ZONE = 0.25;

    public static var P1_CONTROLS = [
        'up'=>FlxKey.UP,
        'down'=>FlxKey.DOWN,
        'left'=>FlxKey.LEFT,
        'right'=>FlxKey.RIGHT,
        'jump'=>FlxKey.Z,
        'shoot'=>FlxKey.X
    ];

    private var isOnGround:Bool;
    private var isLookingUp:Bool;
    private var isLookingDown:Bool;

    private var runSfx:FlxSound;
    private var deathSfx:FlxSound;
    private var jumpSfx:FlxSound;
    private var landSfx:FlxSound;

    private var controls:Map<String, Int>;
    private var controller:FlxGamepad;

    public function new(x:Int, y:Int)
    {
        super(x, y);
        loadGraphic('assets/images/player.png', true, 16, 24);

        width = 5;
        height = 19;
        offset.x = 6;
        offset.y = 5;

        controls = P1_CONTROLS;

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

        runSfx = FlxG.sound.load('assets/sounds/runloop.wav');
        deathSfx = FlxG.sound.load('assets/sounds/death.wav');
        jumpSfx = FlxG.sound.load('assets/sounds/jump.wav');
        landSfx = FlxG.sound.load('assets/sounds/land.wav');
        runSfx.looped = true;
    }

    override public function update(elapsed:Float)
    {
        controller = FlxG.gamepads.getByID(0);
        if(justTouched(FlxObject.FLOOR)) {
            landSfx.play();
        }
        isOnGround = isTouching(FlxObject.DOWN);
        isLookingUp = checkPressed('up');
        isLookingDown = checkPressed('down');
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
        if(checkPressed('left')) {
            if(isOnGround) {
                acceleration.x = -GROUND_ACCEL;
            }
            else {
                acceleration.x = -AIR_ACCEL;
            }
            facing = FlxObject.LEFT;
        }
        else if(checkPressed('right')) {
            if(isOnGround) {
                acceleration.x = GROUND_ACCEL;
            }
            else {
                acceleration.x = AIR_ACCEL;
            }
            facing = FlxObject.RIGHT;
        }
        else {
            if(isOnGround) {
                acceleration.x = 0;
                drag.x = GROUND_DRAG;
            }
            else {
                acceleration.x = 0;
                drag.x = AIR_ACCEL/2;
            }
        }

        if(checkJustPressed('jump') && isOnGround) {
            velocity.y = -JUMP_POWER;
            jumpSfx.play();
        }
        else if(checkJustReleased('jump') && !isOnGround) {
            velocity.y = Math.max(velocity.y, -JUMP_CANCEL_POWER);
        }

        velocity.x = Math.min(velocity.x, SPEED);
        velocity.x = Math.max(velocity.x, -SPEED);
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

    private function checkPressed(name:String) {
        if(controller == null) {
            return FlxG.keys.anyPressed([controls[name]]);
        }
        else {
            if(name == 'shoot') {
                return controller.pressed.X;
            } 
            if(name == 'jump') {
                return controller.pressed.A;
            } 
            if(name == 'left') {
                return controller.analog.value.LEFT_STICK_X < -DEAD_ZONE;
            }
            if(name == 'right') {
                return controller.analog.value.LEFT_STICK_X > DEAD_ZONE;
            }
            if(name == 'up') {
                return controller.analog.value.LEFT_STICK_Y < -DEAD_ZONE;
            }
            if(name == 'down') {
                return controller.analog.value.LEFT_STICK_Y > DEAD_ZONE;
            }
        }
        return false;
    }

    private function checkJustPressed(name:String) {
        if(controller == null) {
            return FlxG.keys.anyJustPressed([controls[name]]);
        }
        else {
            if(name == 'shoot') {
                return controller.justPressed.X;
            } 
            if(name == 'jump') {
                return controller.justPressed.A;
            } 
        }
        return false;
    }

    private function checkJustReleased(name:String) {
        if(controller == null) {
            return FlxG.keys.anyJustReleased([controls[name]]);
        }
        else {
            if(name == 'shoot') {
                return controller.justReleased.X;
            } 
            if(name == 'jump') {
                return controller.justReleased.A;
            } 
        }
        return false;
    }

}
