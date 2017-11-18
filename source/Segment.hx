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

    public function getRandomPosition() {
        var rand = new FlxRandom();
        return {
            x: rand.int(1, widthInTiles - 2),
            y: rand.int(1, heightInTiles - 2)
        }
    }

    public function getRandomOpenPosition() {
        var randomOpenPosition = getRandomPosition();
        while(getTile(randomOpenPosition.x, randomOpenPosition.y) != 0) {
            randomOpenPosition = getRandomPosition();
        }
        return randomOpenPosition;
    }

    public function getEnemyLocation(onGround:Bool) {
        var location = getRandomOpenPosition();
        if(onGround) {
            while(getTile(location.x, location.y + 1) == 0) {
                location.y += 1;
                // Restart if we hit the bottom of the map
                if(location.y >= heightInTiles - 2) {
                    return getEnemyLocation(true);
                }
            }
        }
        var yOffset = 0;
        if(onGround && getTile(location.x, location.y - 1) == 0) {
            yOffset = 8;
        }

        return new FlxPoint(
            x + location.x * Level.TILE_SIZE,
            y + location.y * Level.TILE_SIZE - yOffset
        );
    }

    public function isSpecial() {
        return special;
    }

    public function equals(otherSegment:Segment) {
        return x == otherSegment.x && y == otherSegment.y;
    }
}
