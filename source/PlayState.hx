package;

import flixel.*;

class PlayState extends FlxState
{
    public static inline var MAX_LEVEL_INDEX = 10;
    public static inline var MAX_SEGMENT_INDEX = 0;

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
        for (x in 0...level.widthInTiles) {
            for (y in 0...level.heightInTiles) {
                    if(level.getTile(x, y) == 1) {
                    rand = FlxG.random.int(0, MAX_SEGMENT_INDEX);
                    var segmentPath = 'assets/data/segments/' + rand + '.png';
                    var segment = new Segment(segmentPath);
                    segment.x = x * segment.width;
                    segment.y = y * segment.height;
                    sealSegment(x, y, segment);
                    currentSegment = segment; // temp
                    add(segment);
                }
            }
        }
        FlxG.worldBounds.set(
            0, 0,
            level.widthInTiles * FlxG.width,
            level.heightInTiles * FlxG.height
        );

        // Add player & option
        player = new Player(
            Std.int(currentSegment.x + 50), Std.int(currentSegment.y + 50)
        );
        option = new Option(player);
        add(player);
        add(option);
    }

    private function sealSegment(x:Int, y:Int, segment:Segment) {
        if(!level.hasSegment(x - 1, y)) {
            for (y in 0...segment.heightInTiles) {
                segment.setTile(0, y, 1);
            }
        }
        if(!level.hasSegment(x + 1, y)) {
            for (y in 0...segment.heightInTiles) {
                segment.setTile(segment.widthInTiles - 1, y, 1);
            }
        }
        if(!level.hasSegment(x, y - 1)) {
            for (x in 0...segment.widthInTiles) {
                segment.setTile(x, 0, 1);
            }
        }
        if(!level.hasSegment(x, y + 1)) {
            for (x in 0...segment.widthInTiles) {
                segment.setTile(x, segment.heightInTiles - 1, 1);
            }
        }
    }

    override public function update(elapsed:Float):Void
    {
        Controls.controller = FlxG.gamepads.getByID(0);
        FlxG.overlap(
            player, Segment.all, function(player:FlxObject, segment:FlxObject) {
            currentSegment = cast(segment, Segment);
            FlxObject.separate(player, segment);
        });
        for (bullet in Bullet.all) {
            if(currentSegment.overlaps(bullet)) {
                bullet.destroy();
            }
        }
        FlxG.camera.follow(player, LOCKON, 3);
        FlxG.camera.setScrollBoundsRect(
            currentSegment.x, currentSegment.y,
            currentSegment.width, currentSegment.height
        );
        super.update(elapsed);
    }


}
