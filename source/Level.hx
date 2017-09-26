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
}
