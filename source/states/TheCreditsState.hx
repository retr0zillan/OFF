package states;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import flixel.util.FlxTimer;
import states.*;
import ui.*;
using StringTools;

class TheCreditsState extends MusicBeatState{
    var bg:FlxSprite;
    private var texto:FlxText;
    private var creditos:Array<String> = [];
    private var textoActual:Int = 0;
    var dis:String;
    
    public function new(des:String){
        super();
        this.dis = des;
    }
    override function create()
        {
            super.create();
            cargarCreditosDesdeArchivo("assets/data/creditos.txt");

            switch(dis){
                case 'Batter ending':
                    FlxG.sound.playMusic(Paths.music('myWay','preload'),1, false);

                case 'Judge ending':
                    FlxG.sound.playMusic(Paths.music('Over_the_rainbow','preload'), 1, false);

            }

            bg = new FlxSprite(0,0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
            add(bg);

         
            texto = new FlxText(0, FlxG.height / 2, FlxG.width, " ");
            texto.alignment = CENTER;
            texto.font = 'assets/fonts/offgamefont.otf';
            texto.antialiasing = false;
            texto.size = 72;
            texto.color = 0xffffffff;
    
            add(texto);
              
    

            new FlxTimer().start(4.5, function(_){
                mostrarSiguienteTexto();

            });



        }
        private function cargarCreditosDesdeArchivo(nombreArchivo:String):Void {
            var datos:String = sys.io.File.getContent(nombreArchivo);
            creditos = datos.split("\n");
        }
        private function mostrarSiguienteTexto():Void {
            if (textoActual < creditos.length) {
                texto.alpha = 0;
                texto.text = creditos[textoActual];
                FlxTween.tween(texto, { alpha: 1 }, 4, {ease: FlxEase.expoOut,  onComplete:function(_){
                    new FlxTimer().start(FlxG.random.int(1,3), function(_){
                        ocultarTextoActual();

                    });
                } });
                textoActual++;
            } else {
                // Se han mostrado todos los créditos, volver al menú principal u otra pantalla
                if(FlxG.sound.music.playing){
                    FlxG.sound.music.fadeOut(4,0, function(_){
                        FlxG.switchState(new MapTestState(MapTestState.lastMap));
                    });
                }
                else
                    FlxG.switchState(new MapTestState(MapTestState.lastMap));

               
                // Cambiar a tu estado principal o estado deseado
            }
        }
    
        private function ocultarTextoActual():Void {
            FlxTween.tween(texto, { alpha: 0 }, 4, {ease: FlxEase.expoIn,  onComplete:function(_)
                {
                    mostrarSiguienteTexto();
            }
        });
        }
        override function update(elapsed:Float){
            super.update(elapsed);
            if(textoActual>2){
                if(controls.ACCEPT){
                    FlxG.switchState(new MapTestState(MapTestState.lastMap));
                    // Cambiar a tu estado principal o estado deseado

                }
            }
        }
}