package;

import flixel.*;
import flixel.input.keyboard.*;
import flixel.math.*;


// TODO: Set enemies starting position to rooms they move into
// TODO: Fix bug where sometimes rooms aren't sealed properly

class PlayState extends FlxState
{
    public static inline var MAX_LEVEL_INDEX = 10;
    public static inline var MIN_ENEMY_DISTANCE = 100;
    public static inline var NUMBER_OF_ENEMIES = 45;

    private var level:Level;
    private var currentSegment:Segment;
    private var player:Player;

    private var secretPlayer:SecretPlayer;
    private var option:Option;

    override public function create():Void
    {
        super.create();

        var rand = FlxG.random.int(0, MAX_LEVEL_INDEX);
        var levelPath = 'assets/data/levels/' + rand + '.png';
        trace('level ' + rand);
        level = new Level(levelPath);
        level.generate();
        FlxG.worldBounds.set(
            0, 0,
            level.widthInTiles * FlxG.width,
            level.heightInTiles * FlxG.height
        );

        for(segment in level.segments) {
            add(segment);
        }

        // Add player & option
        var entrance = level.specialSegments.get('entrance');
        currentSegment = entrance;
        player = new Player(
            Std.int(entrance.x + entrance.width/2 - 2),
            Std.int(entrance.y + 3 * Level.TILE_SIZE)
        );
        add(player);
        if(player.isSecret()) {
            secretPlayer = cast(player, SecretPlayer);
            add(secretPlayer.getSword());
            option = new Option(secretPlayer);
            add(option);
        }
        else {
            secretPlayer = null;
            option = null;
        }

        // Add enemies
        for(i in 0...NUMBER_OF_ENEMIES) {
            var enemy:Enemy;
            if(new FlxRandom().bool()) {
                var location = level.getEnemyLocation(true);
                enemy = new Jumper(
                    Std.int(location.x), Std.int(location.y), player
                );
            }
            else {
                var location = level.getEnemyLocation(false);
                enemy = new Parasite(
                    Std.int(location.x), Std.int(location.y), player
                );
            }
            add(enemy);
        }
    }

    public function enterSegment(segment:Segment) {
        var previousSegment:Segment = currentSegment;
        currentSegment = segment;

        // Move enemies in entered segment away from player
        FlxG.overlap(
            currentSegment, Enemy.all,
            function(_:FlxObject, _enemy:FlxObject) {
                var enemy = cast(_enemy, Enemy);
                for(min in [MIN_ENEMY_DISTANCE, MIN_ENEMY_DISTANCE/2]) {
                    for(i in 0...100) {
                        if(FlxMath.distanceBetween(player, enemy) < min) {
                            enemy.resetPosition(
                                currentSegment.getEnemyLocation(
                                    enemy.startsOnGround()
                                )
                            );
                        }
                        else {
                            break;
                        }
                    }
                }
            }
        );

        // Activate enemies in new segment, deactivate and reset in old
        // TODO: Hide this "reset" from the player;
        // currently it's visible for a split second. Could defer resetting
        // by setting a "should reset" variable on the enemy, perhaps..?
        for(_enemy in Enemy.all) {
            var enemy = cast(_enemy, Enemy);
            var inPreviousSegment = FlxG.overlap(enemy, previousSegment);
            var inCurrentSegment = FlxG.overlap(enemy, currentSegment);
            if(inPreviousSegment) {
                enemy.resetPosition();
                enemy.isActive = false;
            }
        }
    }

    override public function update(elapsed:Float):Void
    {
        Controls.controller = FlxG.gamepads.getByID(0);

        // Set current segment
        for(_segment in Segment.all) {
            var segment = cast(_segment, Segment);
            if(
                FlxG.overlap(segment, new FlxObject(player.x, player.y, 0, 0))
                && !cast(segment, Segment).equals(currentSegment)
            ) {

                enterSegment(segment);
            }
        }

        // Collisions
        FlxG.overlap(
            player, Segment.all,
            function(player:FlxObject, segment:FlxObject) {
                FlxObject.separate(player, segment);
            }
        );
        if(option != null) {
            FlxG.collide(option, Segment.all);
        }
        FlxG.collide(Enemy.all, Enemy.all);
        FlxG.collide(Enemy.all, Segment.all);

        for (_enemy in Enemy.all) {
            // Activate enemies close to the player
            var enemy = cast(_enemy, Enemy);
            if(
                FlxG.overlap(currentSegment, enemy)
                && FlxMath.distanceBetween(enemy, player) < Enemy.ACTIVE_RADIUS
            ) {
                enemy.isActive = true;
            }
            // Destroy enemies stuck in walls
            if(currentSegment.overlaps(enemy)) {
                enemy.killQuietly();
            }
        }

        for(bullet in Bullet.all) {
            // Destroy bullets that collide with the current segment's tilemap
            if(currentSegment.overlaps(bullet)) {
                bullet.destroy();
            }
            // Destroy bullets outside the current segment
            if(!FlxG.overlap(bullet, currentSegment)) {
                cast(bullet, Bullet).destroyQuietly();
            }
        }

        FlxG.overlap(
            Bullet.all, Enemy.all,
            function(bullet:FlxObject, enemy:FlxObject) {
                cast(enemy, Enemy).takeHit(Player.SHOT_DAMAGE);
                bullet.destroy();
            }
        );

        if(player.isSecret()) {
            FlxG.overlap(
                secretPlayer.getSword(), Enemy.all,
                function(sword:FlxObject, enemy:FlxObject) {
                    if(sword.visible) {
                        cast(enemy, Enemy).takeHit(SecretPlayer.SLASH_DAMAGE);
                        if(player.x < enemy.x) {
                            player.pushBack(FlxObject.LEFT);
                        }
                        else {
                            player.pushBack(FlxObject.RIGHT);
                        }
                    }
                }
            );
        }

        FlxG.overlap(
            player, Enemy.all,
            function(player:FlxObject, enemy:FlxObject) {
                cast(player, Player).takeHit();
            }
        );

        // Camera
        FlxG.camera.follow(player, LOCKON, 3);
        FlxG.camera.setScrollBoundsRect(
            currentSegment.x, currentSegment.y,
            currentSegment.width, currentSegment.height
        );

        // Debug
        if(FlxG.keys.justPressed.R) {
            FlxG.switchState(new PlayState());
        }
        super.update(elapsed);
    }

    override public function switchTo(nextState:FlxState):Bool
    {
        Enemy.all.clear();
        Segment.all.clear();
        Bullet.all.clear();
        return true;
    }
}
