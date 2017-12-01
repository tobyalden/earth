package;

import flixel.*;
import flixel.effects.*;
import flixel.group.*;
import flixel.math.*;
import flixel.system.*;
import flixel.util.*;

class Mine extends FlxSprite
{
    public static inline var WARN_RADIUS = 100;
    public static inline var DETONATE_RADIUS = 50;

    static public var all:FlxGroup = new FlxGroup();

    private var player:Player;

    private var warnSfx:FlxSound;
    private var preDetonateSfx:FlxSound;

    public function new(x:Int, y:Int, player:Player) {
        super(x, y + 8);
        this.player = player;
        loadGraphic('assets/images/mine.png', true, 16, 16);
        animation.add('idle', [0]);
        animation.add('warn', [1]);
        animation.add('detonate', [2]);
        animation.play('idle');
        all.add(this);
        warnSfx = FlxG.sound.load('assets/sounds/warn.wav');
        preDetonateSfx = FlxG.sound.load('assets/sounds/predetonate.wav');
    }

    override public function update(elapsed:Float) {
        if(FlxMath.distanceBetween(this, player) < DETONATE_RADIUS) {
            animation.play('detonate');
            detonate();
        }
        else if(FlxMath.distanceBetween(this, player) < WARN_RADIUS) {
            if(animation.name == 'idle') {
                animation.play('warn');
                warnSfx.play();
            }
        }
        else {
            animation.play('idle');
        }
    }

    private function detonate() {
        trace('boom!');
    }
}
