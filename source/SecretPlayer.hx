package;

import flixel.*;
import flixel.effects.*;
import flixel.math.*;
import flixel.system.*;
import flixel.util.*;

class SecretPlayer extends Player
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
    public static inline var OPTION_SPEED = 100;
    public static inline var BULLET_SPREAD = 45;
    public static inline var BULLET_KICKBACK_UP = 260;
    public static inline var BULLET_KICKBACK_SIDE = 200;
    public static inline var LIFT_ACCEL = 800;
    public static inline var OPTION_LIFT = 10;
    public static inline var MAX_LIFT_SPEED = 150;
    public static inline var SLASH_COOLDOWN = 0.1;
    public static inline var SLASH_PAUSE = 0.2;
    public static inline var SLASH_DAMAGE = 3;

    private var hangingOnOption:Bool;
    private var sword:FlxSprite;
    private var slashCooldown:FlxTimer;
    private var slashPause:FlxTimer;

    public function new(x:Int, y:Int)
    {
        super(x, y);
        hangingOnOption = false;
        sword = new FlxSprite(0, 0);
        sword.loadGraphic('assets/images/slash.png', true, 80, 32);
        sword.setSize(24, 24);
        sword.animation.add('slash1', [0, 1, 2], 17, false);
        sword.animation.add('slash2', [3, 4, 5], 17, false);
        sword.setFacingFlip(FlxObject.LEFT, true, false);
        sword.setFacingFlip(FlxObject.RIGHT, false, false);
        sword.animation.play('slash1');
        slashCooldown = new FlxTimer();
        slashPause = new FlxTimer();
    }

    public function getSword() {
        return sword;
    }

    private function setSwordPosition() {
        sword.facing = facing;
        sword.y = y - (sword.height - height)/2;
        sword.offset.y = 11;
        if(facing == FlxObject.LEFT) {
            sword.x = x - sword.width;
            sword.offset.x = 20;
        }
        else {
            sword.x = x + width;
            sword.offset.x = 36;
        }
    }

    override public function update(elapsed:Float)
    {
        if(slashPause.active) {
            if(isOnGround && !pushback.active) {
                velocity.x = 0;
                acceleration.x = 0;
            }
        }
        if(!slashCooldown.active) {
            if(Controls.checkJustPressed('shoot')) {
                slashCooldown.start(SLASH_COOLDOWN);
                if(isOnGround) {
                    slashPause.start(SLASH_PAUSE);
                }
                sword.visible = true;
                if(sword.animation.name == 'slash1') {
                    sword.animation.play('slash2');
                }
                else {
                    sword.animation.play('slash1');
                }
            }
        }
        if(sword.animation.finished) {
            sword.visible = false;
        }
        setSwordPosition();
        super.update(elapsed);
    }

    override private function move()
    {
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
            if(isOnGround || wasOnGround.active) {
                velocity.y = -JUMP_POWER;
                jumpSfx.play();
                isOnGround = false;
                wasOnGround.cancel();
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

        var maxSpeed = SPEED;
        if(pushback.active) {
            maxSpeed = PUSHBACK_SPEED;
        }
        else if(hangingOnOption) {
            maxSpeed = OPTION_SPEED;
        }
        velocity.x = Math.min(velocity.x, maxSpeed);
        velocity.x = Math.max(velocity.x, -maxSpeed);
        if(hangingOnOption) {
            velocity.y = Math.max(
                velocity.y - OPTION_LIFT, -MAX_LIFT_SPEED
            );
        }
        else {
            velocity.y = Math.min(velocity.y + GRAVITY, TERMINAL_VELOCITY);
        }
    }

    public function isHangingOnOption() {
        return hangingOnOption;
    }

    override private function respawn(_:FlxTimer) {
        hangingOnOption = false;
        super.respawn(null);
    }

    override public function isSecret() {
        return true;
    }
}
