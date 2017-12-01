package;

import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.tile.*;

class Segment extends FlxTilemap
{
    public static var all:FlxGroup = new FlxGroup();

    public var special:Bool;
    public var decorativeTiles:FlxTilemap;

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

    public function getDecorativeTiles() {
        decorativeTiles = new FlxTilemap();
        decorativeTiles.x = x;
        decorativeTiles.y = y;
        var data = getData(true);
        for(tileX in 0...widthInTiles) {
            for(tileY in 0...heightInTiles) {
                var tileIndex = tileX + tileY * widthInTiles;
                if(data[tileIndex] == 1) {
                    data[tileIndex] = (
                        Std.int(x / FlxG.width) * 16 + tileX + tileY * 100
                    );
                }
                else {
                    data[tileIndex] = -1;
                }
            }
        }
        decorativeTiles.loadMapFromArray(
            data, widthInTiles, heightInTiles, 'assets/images/stonebig.png',
            16, 16, 0, 0
        );
        return decorativeTiles;
    }

    public function getWater() {
        var waters = new Array<Water>();
        for(tileY in 0...heightInTiles) {
            for(tileX in 0...widthInTiles) {
                if(
                    getTile(tileX, tileY) == 0
                    && getTile(tileX, tileY + 1) > 0
                    && getTile(tileX - 1, tileY) > 0
                ) {
                    var canHoldWater = true;
                    var tileCount = 1;
                    for(stepX in (tileX + 1)...widthInTiles) {
                        if(getTile(stepX, tileY) > 1) {
                            break;
                        }
                        if(getTile(stepX, tileY + 1) == 0) {
                            canHoldWater = false;
                            break;
                        }
                        tileCount++;
                    }
                    if(canHoldWater) {
                        var water = new Water(
                            Std.int(x + tileX * Level.TILE_SIZE),
                            Std.int(y + tileY * Level.TILE_SIZE),
                            tileCount * Level.TILE_SIZE
                        );
                        waters.push(water);
                        break;
                    }
                }
            }
        }
        return waters;
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

    public function getRandomOpenPosition() {
        var randomOpenPosition = getRandomPosition();
        while(getTile(randomOpenPosition.x, randomOpenPosition.y) != 0) {
            randomOpenPosition = getRandomPosition();
        }
        return randomOpenPosition;
    }

    public function getEnemyLocation(placement:Int) {
        var location = getRandomOpenPosition();
        if(placement == FlxObject.FLOOR) {
            while(getTile(location.x, location.y + 1) == 0) {
                location.y += 1;
                // Restart if we hit the bottom of the map
                if(location.y >= heightInTiles - 2) {
                    return getEnemyLocation(FlxObject.FLOOR);
                }
            }
        }
        else if(placement == FlxObject.CEILING) {
            while(getTile(location.x, location.y - 1) == 0) {
                location.y -= 1;
                // Restart if we hit the top of the map
                if(location.y <= 1) {
                    return getEnemyLocation(FlxObject.CEILING);
                }
            }
        }
        var yOffset = 0;
        if(
            placement == FlxObject.FLOOR
            && getTile(location.x, location.y - 1) == 0
        ) {
            yOffset = 8;
        }
        else if(
            placement == FlxObject.CEILING
            && getTile(location.x, location.y + 1) == 0
        ) {
            yOffset = -8;
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
