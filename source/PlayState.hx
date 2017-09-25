package;

import flixel.*;
import flixel.tile.*;

class PlayState extends FlxState
{
    private var map:FlxTilemap;
    private var player:Player;
    private var option:Option;

    override public function create():Void
    {
        super.create();

        // Add map
        var mapPath = 'assets/data/maps/0.png';
        var tilesetPath = 'assets/images/tiles.png';
        map = new FlxTilemap();
        map.loadMapFromGraphic(mapPath, false, 1, tilesetPath, 16, 16, AUTO);
        add(map);

        // Add player & option
        player = new Player(50, 50);
        option = new Option(player);
        add(player);
        add(option);
    }

    override public function update(elapsed:Float):Void
    {
        FlxG.collide(player, map);
        Controls.controller = FlxG.gamepads.getByID(0);
        super.update(elapsed);
    }
}
