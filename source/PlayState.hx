package;

import flixel.*;

class PlayState extends FlxState
{
    private var level:Level;
    private var currentSegment:Segment;
    private var player:Player;
    private var option:Option;

    override public function create():Void
    {
        super.create();

        var levelPath = 'assets/data/levels/1.png';
        level = new Level(levelPath);
        for (x in 0...level.widthInTiles) {
            for (y in 0...level.heightInTiles) {
                    if(level.getTile(x, y) == 1) {
                    var segmentPath = 'assets/data/segments/0.png';
                    var segment = new Segment(segmentPath);
                    segment.x = x * segment.width;
                    segment.y = y * segment.height;
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
        player = new Player(50, 50);
        option = new Option(player);
        add(player);
        add(option);
    }

    override public function update(elapsed:Float):Void
    {
        Controls.controller = FlxG.gamepads.getByID(0);
        FlxG.overlap(
            player, Segment.all, function(player:FlxObject, segment:FlxObject) {
            currentSegment = cast(segment, Segment);
            FlxObject.separate(player, segment);
        });
        FlxG.camera.follow(player, LOCKON, 3);
        FlxG.camera.setScrollBoundsRect(
            currentSegment.x, currentSegment.y,
            currentSegment.width, currentSegment.height
        );
        super.update(elapsed);
    }


}
