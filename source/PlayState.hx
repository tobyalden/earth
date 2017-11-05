package;

import flixel.*;
import flixel.input.keyboard.*;
import flixel.math.*;

class PlayState extends FlxState
{
    public static inline var MAX_LEVEL_INDEX = 11;
    public static inline var MIN_ENEMY_DISTANCE = 100;

    private var level:Level;
    private var currentSegment:Segment;
    private var player:Player;
    private var option:Option;

    override public function create():Void
    {
        super.create();

        var rand = FlxG.random.int(0, MAX_LEVEL_INDEX);
        var levelPath = 'assets/data/levels/' + rand + '.png';
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
        option = new Option(player);
        add(player);
        add(player.getSword());
        add(option);

        // Add enemies
        var enemyLocations = level.getEnemyLocations(100);
        for(enemyLocation in enemyLocations) {
            var parasite = new Parasite(
                Std.int(enemyLocation.x), Std.int(enemyLocation.y), player
            );
            add(parasite);
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
                currentSegment = segment;
                FlxG.overlap(
                    currentSegment, Enemy.all,
                    function(_:FlxObject, _enemy:FlxObject) {
                        var enemy = cast(_enemy, Enemy);
                        while(
                            FlxMath.distanceBetween(player, enemy)
                            < MIN_ENEMY_DISTANCE
                        ) {
                            enemy.resetPosition(segment.getEnemyLocation());
                        }
                    }
                );
                break;
            }
        }

        // Collisions
        FlxG.overlap(
            player, Segment.all,
            function(player:FlxObject, segment:FlxObject) {
                FlxObject.separate(player, segment);
            }
        );
        FlxG.collide(option, Segment.all);
        FlxG.collide(Enemy.all, Enemy.all);
        FlxG.collide(Enemy.all, Segment.all);
        for(enemy in Enemy.all) {
            cast(enemy, Enemy).isActive = FlxG.overlap(enemy, currentSegment);
        }

        // Destroy enemies stuck in walls
        for (enemy in Enemy.all) {
            if(currentSegment.overlaps(enemy)) {
                enemy.destroy();
            }
        }
        for (bullet in Bullet.all) {
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
                cast(enemy, Enemy).takeHit(1);
                bullet.destroy();
            }
        );

        FlxG.overlap(
            player.getSword(), Enemy.all,
            function(sword:FlxObject, enemy:FlxObject) {
                if(sword.visible) {
                    cast(enemy, Enemy).takeHit(0);
                    if(player.x < enemy.x) {
                        player.pushBack(FlxObject.LEFT);
                    }
                    else {
                        player.pushBack(FlxObject.RIGHT);
                    }
                }
            }
        );

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
}
