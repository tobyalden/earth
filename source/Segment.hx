package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.tile.*;

class Segment extends FlxTilemap
{
    public static var all:FlxGroup = new FlxGroup();

    public function new(path:String)
    {
        super();
        all.add(this);
        loadMapFromGraphic(
            path, false, 1, 'assets/images/tiles.png', 16, 16, AUTO
        );
    }

    public function getRandomTile() {
        var rand = new FlxRandom();
        return getTile(rand.int(0, widthInTiles), rand.int(0, heightInTiles));
    }

    public function getRandomOpenTile() {

    }

}
