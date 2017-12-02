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
    public static inline var DETONATE_DELAY = 1;

    static public var all:FlxGroup = new FlxGroup();

    private var player:Player;

    private var warnSfx:FlxSound;
    private var preDetonateSfx:FlxSound;
    private var explodeSfx:FlxSound;
    private var isDetonating:Bool;
    private var detonateTimer:FlxTimer;

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
        explodeSfx = FlxG.sound.load('assets/sounds/explode.wav');
        isDetonating = false;
        detonateTimer = new FlxTimer();
    }

    override public function update(elapsed:Float) {
        if(isDetonating) {
            // do nothing
        }
        else if(FlxMath.distanceBetween(this, player) < DETONATE_RADIUS) {
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
        super.update(elapsed);
    }

    private function detonate() {
        isDetonating = true;
        animation.play('detonate');
        preDetonateSfx.play();
        detonateTimer.start(DETONATE_DELAY, function(_:FlxTimer) {
            explode();
        });
    }

    public function explode() {
        FlxG.state.add(new TrapExplosion(this));
        explodeSfx.play();
        kill();
    }
}
