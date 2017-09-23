package;

import flixel.*;
import flixel.tile.*;

class PlayState extends FlxState
{
    private var map:FlxTilemap;

    override public function create():Void
    {
        super.create();
        var mapPath = 'assets/data/maps/0.png';
        var tilesetPath = 'assets/images/tiles.png';
        map = new FlxTilemap();
        map.loadMapFromGraphic(mapPath, false, 1, tilesetPath, 16, 16, AUTO);
        add(map);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}
