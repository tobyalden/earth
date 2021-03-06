package;

import flixel.*;
import flixel.group.*;
import flixel.input.keyboard.*;
import flixel.math.*;
import flixel.system.*;
import flixel.util.*;


class PlayState extends FlxState
{
    public static inline var MAX_LEVEL_INDEX = 10;
    public static inline var MIN_ENEMY_DISTANCE = 100;
    public static inline var NUMBER_OF_ENEMIES = 7;
    public static inline var NUMBER_OF_TRAPS = 5;

    private var level:Level;
    private var currentSegment:Segment;
    private var player:Player;

    private var key:Key;
    private var door:Door;

    private var secretPlayer:SecretPlayer;
    private var option:Option;


    public var levelCompleteSfx:FlxSound;
    private var depth:Int;
    private var depthDisplay:DepthDisplay;

    // TODO: Randomly flip levels horizontally
    // TODO: Move sound effects into static variables
    // TODO: Fix bug where enemies with downward velocity spawn through the floor
    // TODO: Fix bug where water can spawn on the edge of a level

    override public function create():Void
    {
        super.create();

        levelCompleteSfx = FlxG.sound.load('assets/sounds/levelcomplete.ogg');
        depth = 1;

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


        var backdrop = new FlxSprite(
            0, 0, 'assets/images/backgroundbig${depth}.png'
        );
        add(backdrop);
        var segments = new Array<Segment>();
        for (segment in Segment.all) {
            segments.push(cast(segment, Segment));
        }
        for(segment in segments) {
            segment.alpha = 0.80;
            //segment.useScaleHack = false;
            add(segment);
        }

        // Set special rooms
        var entrance = level.specialSegments.get('entrance');
        var keySegment = level.specialSegments.get('key');
        var exit = level.specialSegments.get('exit');
        currentSegment = entrance;

        // Add key and door
        key = new Key(
            Std.int(keySegment.x + keySegment.width/2 - Level.TILE_SIZE/2),
            Std.int(keySegment.y + keySegment.height/2 - Level.TILE_SIZE*1.25)
        );
        add(key);
        door = new Door(
            Std.int(exit.x + exit.width/2 - Level.TILE_SIZE),
            Std.int(exit.y + exit.height/2 - Level.TILE_SIZE/2)
        );
        add(door);

        // Add player & option
        player = new Player(
            Std.int(entrance.x + entrance.width/2 - 2),
            Std.int(entrance.y + 6 * Level.TILE_SIZE)
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


        // Add enemies and traps
        addEnemies();
        for(i in 0...NUMBER_OF_TRAPS) {
            var location = level.getEnemyLocation(FlxObject.FLOOR);
            var trap = new Mine(
                Std.int(location.x), Std.int(location.y), player
            );
            add(trap);
        }

        // Add decorations
        for(segment in segments) {
            for(decorativeTiles in segment.getDecorativeTiles(depth)) {
                add(decorativeTiles);
            }
        }

        // Add water
        for(segment in segments) {
            var waters = segment.getWater();
            for(water in waters) {
                water.alpha = 0.5;
                add(water);
            }
        }

        depthDisplay = new DepthDisplay(
            Std.int(entrance.x), Std.int(entrance.y), depth
        );
        add(depthDisplay);
    }

    private function addEnemies() {
        for(i in 0...(NUMBER_OF_ENEMIES + depth)) {
            var rand = new FlxRandom().int(1, depth + 5);
            trace(rand);
            var enemy:Enemy;
            if(rand <= 3) {
                enemy = new Parasite(0, 0, player);
            }
            else if(rand == 4) {
                enemy = new Jumper(0, 0, player);
            }
            else if(rand == 5) {
                enemy = new Seer(0, 0, player);
            }
            else if(rand == 6) {
                enemy = new Guardian(0, 0, player);
            }
            else {
                enemy = new Parasite(0, 0, player);
            }
            var location = level.getEnemyLocation(enemy.getPlacement());
            enemy.setPosition(Std.int(location.x), Std.int(location.y + 8));
            add(enemy);
        }
    }

    public function getNotGhosts() {
        var notGhosts = new FlxGroup();
        for(_enemy in Enemy.all) {
            var enemy = cast(_enemy, Enemy);
            if(!enemy.isGhost()) {
                notGhosts.add(enemy);
            }
        }
        return notGhosts;
    }

    public function enterSegment(segment:Segment) {
        trace('entering segment: ' + segment);
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
                                    enemy.getPlacement()
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
        for(_enemy in Enemy.all) {
            var enemy = cast(_enemy, Enemy);
            var inPreviousSegment = FlxG.overlap(enemy, previousSegment);
            var inCurrentSegment = FlxG.overlap(enemy, currentSegment);
            if(inPreviousSegment) {
                enemy.resetPosition();
                enemy.deactivate();
            }
        }
    }

    override public function update(elapsed:Float):Void
    {
        Controls.controller = FlxG.gamepads.getByID(0);

        // Enter segments
        for(_segment in Segment.all) {
            var segment = cast(_segment, Segment);
            if(
                FlxG.overlap(segment, new FlxObject(player.x, player.y, 0, 0))
                && !cast(segment, Segment).equals(currentSegment)
            ) {

                enterSegment(segment);
            }
        }

        // Solid collisions
        FlxG.overlap(
            player, Segment.all,
            function(player:FlxObject, segment:FlxObject) {
                FlxObject.separate(player, segment);
            }
        );
        if(option != null) {
            FlxG.collide(option, Segment.all);
        }
        FlxG.collide(getNotGhosts(), Enemy.all);
        FlxG.collide(getNotGhosts(), Segment.all);

        // Key & door
        FlxG.overlap(player, key, function(player:FlxObject, key:FlxObject) {
            key.kill();
            door.open();
        });
        FlxG.overlap(player, door, function(player:FlxObject, door:FlxObject) {
            if(cast(door, Door).isOpen()) {
                goToNextLevel();
            }
        });


        for (_enemy in Enemy.all) {
            // Activate enemies close to the player
            var enemy = cast(_enemy, Enemy);
            if(
                FlxG.overlap(currentSegment, enemy)
                && FlxMath.distanceBetween(enemy, player) < Enemy.ACTIVE_RADIUS
            ) {
                enemy.activate();
            }
            // Destroy enemies stuck in walls
            if(currentSegment.overlaps(enemy) && !enemy.isGhost()) {
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

        for(bullet in EnemyBullet.all) {
            // Destroy bullets that collide with the current segment's tilemap
            if(currentSegment.overlaps(bullet)) {
                bullet.destroy();
            }
            // Destroy bullets outside the current segment
            if(!FlxG.overlap(bullet, currentSegment)) {
                cast(bullet, EnemyBullet).destroyQuietly();
            }
        }

        // Damage enemies
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

        // Collide player with bullets and traps
        for(danger in [EnemyBullet.all, TrapExplosion.all]) {
            FlxG.overlap(
                player, danger,
                function(_:FlxObject, _:FlxObject) {
                    player.takeHit();
                }
            );
        }

        // Collide player with enemies
        FlxG.overlap(
            player, Enemy.all,
            function(_:FlxObject, enemy:FlxObject) {
                if(cast(enemy, Enemy).willDamageOnTouch()) {
                    player.takeHit();
                }
                else {
                    FlxG.collide(player, enemy);
                }
            }
        );


        // Handle traps
        FlxG.overlap(
            TrapExplosion.all, Enemy.all,
            function(_:FlxObject, enemy:FlxObject) {
                cast(enemy, Enemy).takeHit(TrapExplosion.DAMAGE);
            }
        );
        FlxG.overlap(
            TrapExplosion.all, Mine.all,
            function(_:FlxObject, mine:FlxObject) {
                cast(mine, Mine).explode();
            }
        );

        player.isInWater = FlxG.overlap(player, Water.all);

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

    private function goToNextLevel() {
        player.freeze();
        levelCompleteSfx.play();
        FlxG.camera.fade(FlxColor.BLACK, 2.5, false, function() {
            FlxG.switchState(new PlayState());
        });
    }

    override public function switchTo(nextState:FlxState):Bool
    {
        Enemy.all.clear();
        Segment.all.clear();
        Bullet.all.clear();
        return true;
    }
}
