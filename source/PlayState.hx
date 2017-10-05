package;

import flixel.*;

class PlayState extends FlxState
{
    public static inline var MAX_LEVEL_INDEX = 11;

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
            currentSegment = segment; // temp
        }

        // Add player & option
        player = new Player(
            Std.int(currentSegment.x + 50), Std.int(currentSegment.y + 50)
        );
        option = new Option(player);
        add(player);
        add(option);

        var parasite = new Parasite(
            Std.int(currentSegment.x + 75), Std.int(currentSegment.y + 75),
            player
        );
        add(parasite);
    }

    override public function update(elapsed:Float):Void
    {
        Controls.controller = FlxG.gamepads.getByID(0);

        // Collisions
        FlxG.overlap(
            player, Segment.all, function(player:FlxObject, segment:FlxObject) {
            currentSegment = cast(segment, Segment);
            FlxObject.separate(player, segment);
        });
        FlxG.collide(option, Segment.all);
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

        // Camera
        FlxG.camera.follow(player, LOCKON, 3);
        FlxG.camera.setScrollBoundsRect(
            currentSegment.x, currentSegment.y,
            currentSegment.width, currentSegment.height
        );
        super.update(elapsed);
    }


}
