package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.tile.*;

class Segment extends FlxTilemap
{
    public static var all:FlxGroup = new FlxGroup();

    public var special:Bool;

    public function new(path:String, special:Bool=false)
    {
        super();
        this.special = special;
        all.add(this);
        loadMapFromGraphic(
            path, false, 1, 'assets/images/tiles.png', 16, 16, AUTO
        );
    }

    public function getRandomTile() {
        var rand = new FlxRandom();
        return getTile(rand.int(0, widthInTiles), rand.int(0, heightInTiles));
    }

    public function getEnemyLocation() {
        var rand = new FlxRandom();
        var randX = rand.int(0, widthInTiles);
        var randY = rand.int(0, heightInTiles);
        while(getTile(randX, randY) != 0) {
            randX = rand.int(0, widthInTiles);
            randY = rand.int(0, heightInTiles);
        }
        return new FlxPoint(
            x + randX * Level.TILE_SIZE, y + randY * Level.TILE_SIZE
        );
    }

    public function isSpecial() {
        return special;
    }
}
