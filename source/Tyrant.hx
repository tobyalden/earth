package;

class Tyrant extends Guardian
{
    public function new(x:Int, y:Int, player:Player) {
        super(x, y, player);
        loadGraphic('assets/images/tyrant.png', true, 16, 16);
        animation.add('red', [0]);
        animation.add('green', [1]);
        animation.add('off', [2]);
        animation.play('off');
    }
}
