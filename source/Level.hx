package;

import flixel.*;
import flixel.tile.*;

class Level extends FlxTilemap
{
    public static inline var TILE_SIZE = 16;
    public static inline var MIN_SEGMENT_WIDTH_IN_TILES = 20;
    public static inline var MIN_SEGMENT_HEIGHT_IN_TILES = 15;
    public static inline var MIN_SEGMENT_WIDTH = (
        MIN_SEGMENT_WIDTH_IN_TILES * TILE_SIZE
    );
    public static inline var MIN_SEGMENT_HEIGHT = (
        MIN_SEGMENT_HEIGHT_IN_TILES * TILE_SIZE
    );

    public static var MAX_SEGMENT_INDEXES = [
        '1x1' => 10,
        '2x2' => 0,
        '3x3' => 0,
        '3x1' => 0
    ];

    public var segments:Map<String, Segment>;

    public function new(path:String)
    {
        super();
        segments = new Map<String, Segment>();
        loadMapFromGraphic(path, false, 1, 'assets/images/tiles.png');
    }

    public function generate() {
        // Add special segments
        makeEntrance();

        // Add large segments
        makeSegment(2, 2);
        makeSegment(3, 1);

        // Fill remaining spaces with 1x1 segments
        for (tileX in 0...widthInTiles) {
            for (tileY in 0...heightInTiles) {
                if(!hasSegment(tileX, tileY)) {
                    makeSegment(1, 1);
                }
            }
        }
    }

    private function sealSegments(
        segmentX:Int, segmentY:Int, segmentWidth:Int, segmentHeight:Int,
        segment:Segment
    ) {
        for(widthX in 0...segmentWidth) {
            for(heightY in 0...segmentHeight) {
                sealSegment(
                    segmentX + widthX, segmentY + heightY, widthX, heightY,
                    segment
                );
            }
        }
    }

    private function sealSegment(
        segmentX:Int, segmentY:Int, offsetX:Int, offsetY:Int, segment:Segment
    ) {
        var tileOffsetX = offsetX * MIN_SEGMENT_WIDTH_IN_TILES;
        var tileOffsetY = offsetY * MIN_SEGMENT_HEIGHT_IN_TILES;
        var tileLimitX = tileOffsetX + MIN_SEGMENT_WIDTH_IN_TILES;
        var tileLimitY = tileOffsetY + MIN_SEGMENT_HEIGHT_IN_TILES;
        if(!inLevel(segmentX - 1, segmentY)) {
            for (tileY in tileOffsetY...tileLimitY) {
                segment.setTile(0, tileY, 1);
            }
        }
        if(!inLevel(segmentX + 1, segmentY)) {
            for (tileY in tileOffsetY...tileLimitY) {
                segment.setTile(
                    tileOffsetX + MIN_SEGMENT_WIDTH_IN_TILES - 1, tileY, 1
                );
            }
        }
        if(!inLevel(segmentX, segmentY - 1)) {
            for (tileX in tileOffsetX...tileLimitX) {
                segment.setTile(tileX, 0, 1);
            }
        }
        if(!inLevel(segmentX, segmentY + 1)) {
            for (tileX in tileOffsetX...tileLimitX) {
                segment.setTile(
                    tileX, tileOffsetY + MIN_SEGMENT_HEIGHT_IN_TILES - 1, 1
                );
            }
        }
    }

    public function makeEntrance() {
    }

    public function makeSegment(
        segmentWidth:Int, segmentHeight:Int, ?segmentName:String=null
    ) {
        for(segmentX in 0...widthInTiles) {
            for(segmentY in 0...heightInTiles) {
                if(canPlaceSegment(
                    segmentX, segmentY, segmentWidth, segmentHeight
                )) {
                    var segmentKey = segmentWidth + 'x' + segmentHeight;
                    var rand = FlxG.random.int(
                        0, MAX_SEGMENT_INDEXES[segmentKey]
                    );
                    var segmentPath = 'assets/data/segments/';
                    if(segmentName == null) {
                        segmentPath += segmentKey + '/' + rand + '.png';
                    }
                    else {
                        segmentPath += segmentName + '.png';
                    }
                    var segment = new Segment(segmentPath);
                    segment.x = segmentX * MIN_SEGMENT_WIDTH;
                    segment.y = segmentY * MIN_SEGMENT_HEIGHT;
                    setSegments(
                        segmentX, segmentY, segmentWidth, segmentHeight,
                        segment
                    );
                    sealSegments(
                        segmentX, segmentY, segmentWidth, segmentHeight,
                        segment
                    );
                    return;
                }
            }
        }
    }

    public function inLevel(segmentX:Int, segmentY:Int) {
        return getTile(segmentX, segmentY) > 0;
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

    public function setSegments(
        segmentX:Int, segmentY:Int, segmentWidth:Int, segmentHeight:Int,
        segment:Segment
    ) {
        for(widthX in 0...segmentWidth) {
            for(heightY in 0...segmentHeight) {
                setSegment(segmentX + widthX, segmentY + heightY, segment);
            }
        }
    }

    public function canPlace1x1Segment(segmentX:Int, segmentY:Int) {
        return inLevel(segmentX, segmentY) && !hasSegment(segmentX, segmentY);
    }

    public function canPlaceSegment(
        segmentX:Int, segmentY:Int, segmentWidth:Int, segmentHeight:Int
    ) {
        for(widthX in 0...segmentWidth) {
            for(heightY in 0...segmentHeight) {
                if(
                    !canPlace1x1Segment(segmentX + widthX, segmentY + heightY)
                ) {
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

}
