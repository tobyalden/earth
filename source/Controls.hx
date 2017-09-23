package;

import flixel.*;
import flixel.input.gamepad.*;
import flixel.input.keyboard.*;

class Controls {

    public static inline var DEAD_ZONE = 0.25;
    public static var KEYBOARD_CONTROLS = [
        'up'=>FlxKey.UP,
        'down'=>FlxKey.DOWN,
        'left'=>FlxKey.LEFT,
        'right'=>FlxKey.RIGHT,
        'jump'=>FlxKey.Z,
        'shoot'=>FlxKey.X
    ];

    public static var controller:FlxGamepad;
    public static var controls:Map<String, Int> = KEYBOARD_CONTROLS;

    public static function checkPressed(name:String) {
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

    public static function checkJustPressed(name:String) {
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

    public static function checkJustReleased(name:String) {
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
