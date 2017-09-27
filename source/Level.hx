package;

import flixel.*;
import flixel.tile.*;

class Level extends FlxTilemap
{
    public static inline var TILE_SIZE = 16;
    public static inline var MIN_SEGMENT_WIDTH = 20 * TILE_SIZE;
    public static inline var MIN_SEGMENT_HEIGHT = 15 * TILE_SIZE;
    public static inline var MAX_SEGMENT_INDEX = 10;
    public static inline var MAX_2X2_SEGMENT_INDEX = 0;

    public var segments:Map<String, Segment>;

    public function new(path:String)
    {
        super();
        segments = new Map<String, Segment>();
        loadMapFromGraphic(path, false, 1, 'assets/images/tiles.png');
    }

    public function inLevel(tileX:Int, tileY:Int) {
        return getTile(tileX, tileY) > 0;
    }

    public function getSegment(segmentX:Int, segmentY:Int) {
        return segments.get([segmentX, segmentY].toString());
    }

    public function hasSegment(segmentX:Int, segmentY:Int) {
        return segments.get([segmentX, segmentY].toString()) != null;
    }

    public function setSegment(segmentX:Int, segmentY:Int, segment:Segment) {
        segments.set([segmentX, segmentY].toString(), segment);
    }

    public function canPlace1x1Segment(segmentX:Int, segmentY:Int) {
        return inLevel(segmentX, segmentY) && !hasSegment(segmentX, segmentY);
    }

    public function canPlaceSegment(
        segmentX:Int, segmentY:Int, segmentWidth:Int, segmentHeight:Int
    ) {
        for(widthIndex in 0...segmentWidth) {
            for(heightIndex in 0...segmentHeight) {
                if(!canPlace1x1Segment(
                        segmentX + widthIndex, segmentY + heightIndex
                )) {
                    return false;
                }
            }
        }
        return true;
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

    public function generate() {
        add2x2();
        // Fill remaining spaces with 1x1 segments
        for (x in 0...widthInTiles) {
            for (y in 0...heightInTiles) {
                if(canPlace1x1Segment(x, y)) {
                    var rand = FlxG.random.int(0, MAX_SEGMENT_INDEX);
                    var segmentPath = 'assets/data/segments/' + rand + '.png';
                    var segment = new Segment(segmentPath);
                    segment.x = x * MIN_SEGMENT_WIDTH;
                    segment.y = y * MIN_SEGMENT_HEIGHT;
                    sealSegment(x, y, segment);
                    setSegment(x, y, segment);
                }
            }
        }
    }

    private function sealSegment(x:Int, y:Int, segment:Segment) {
        if(!inLevel(x - 1, y)) {
            for (y in 0...segment.heightInTiles) {
                segment.setTile(0, y, 1);
            }
        }
        if(!inLevel(x + 1, y)) {
            for (y in 0...segment.heightInTiles) {
                segment.setTile(segment.widthInTiles - 1, y, 1);
            }
        }
        if(!inLevel(x, y - 1)) {
            for (x in 0...segment.widthInTiles) {
                segment.setTile(x, 0, 1);
            }
        }
        if(!inLevel(x, y + 1)) {
            for (x in 0...segment.widthInTiles) {
                segment.setTile(x, segment.heightInTiles - 1, 1);
            }
        }
    }

    // TODO: Refactor into method (makeRoom)
    //public function makeRoom(sizeX:Int, sizeY:Int) {
    public function add2x2() {
        for(x in 0...widthInTiles) {
            for(y in 0...heightInTiles) {
                if(canPlaceSegment(x, y, 2, 2)) {
                    var rand = FlxG.random.int(0, MAX_2X2_SEGMENT_INDEX);
                    var segmentPath = (
                        'assets/data/segments/2x2/' + rand + '.png'
                    );
                    var segment = new Segment(segmentPath);
                    segment.x = x * MIN_SEGMENT_WIDTH;
                    segment.y = y * MIN_SEGMENT_HEIGHT;
                    //sealSegment(x, y, segment);
                    setSegment(x, y, segment);
                    setSegment(x + 1, y, segment);
                    setSegment(x, y + 1, segment);
                    setSegment(x + 1, y + 1, segment);
                    return;
                }
            }
        }
    }

}
