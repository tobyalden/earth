package;

import flixel.*;
import flixel.tile.*;

class Level extends FlxTilemap
{
    public static inline var MAX_SEGMENT_INDEX = 10;

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

    public function setSegment(segmentX:Int, segmentY:Int, segment:Segment) {
        segments.set([segmentX, segmentY].toString(), segment);
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
        for (x in 0...widthInTiles) {
            for (y in 0...heightInTiles) {
                if(inLevel(x, y)) {
                    var rand = FlxG.random.int(0, MAX_SEGMENT_INDEX);
                    var segmentPath = 'assets/data/segments/' + rand + '.png';
                    var segment = new Segment(segmentPath);
                    segment.x = x * segment.width;
                    segment.y = y * segment.height;
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

}
