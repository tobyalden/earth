package;

import flixel.*;
import flixel.tile.*;

class Level extends FlxTilemap
{
    public function new(path:String)
    {
        super();
        loadMapFromGraphic(path, false, 1, 'assets/images/tiles.png');
    }

    public function hasSegment(tileX:Int, tileY:Int) {
        return getTile(tileX, tileY) > 0;
    }

    override function getTile(tileX:Int, tileY:Int) {
        if (
            tileX < 0 || tileX >= widthInTiles
            || tileY < 0 || tileY >= heightInTiles
        ) {
            return -1;
        }
        return super.getTile(tileX, tileY);
    }
}
