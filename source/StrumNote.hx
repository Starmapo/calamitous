package;

import flixel.FlxG;
import flixel.FlxSprite;
import UIData;
#if MODS_ALLOWED
import sys.FileSystem;
#end
import openfl.utils.Assets;

using StringTools;

class StrumNote extends FlxSprite
{
	private var colorSwap:ColorSwap;
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;
	public var direction:Float = 90;//plan on doing scroll directions soon -bb
	public var downScroll:Bool = false;//plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;

	private var player:Int;

	var keyAmount:Int = 4;
	var directions:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	var colors:Array<String> = ['left', 'down', 'up', 'right'];
	public var swagWidth:Float = 160 * 0.7;
	var xOff:Float = 54;
	public var noteSize:Float = 0.7;
	public var uiSkin:SkinFile;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, player:Int, ?keyAmount:Int = 4, ?uiSkin:SkinFile = null) {
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		if (uiSkin == null) {
			uiSkin = UIData.getUIFile('');
		}
		this.player = player;
		this.noteData = leData;
		this.keyAmount = keyAmount;
		this.uiSkin = uiSkin;
		super(x, y);

		var maniaData:ManiaArray = null;
		for (i in uiSkin.mania) {
			if (i.keys == keyAmount) {
				maniaData = i;
				break;
			}
		}
		if (maniaData == null) {
			var bad:SkinFile = UIData.getUIFile('default');
			for (i in bad.mania) {
				if (i.keys == keyAmount) {
					maniaData = i;
					break;
				}
			}
		}

		directions = maniaData.directions;
		colors = maniaData.colors;
		swagWidth = maniaData.noteSpacing;
		xOff = maniaData.xOffset;
		noteSize = maniaData.noteSize;

		var skin:String = 'NOTE_assets';
		texture = skin; //Load texture and anims

		scrollFactor.set();
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;
		var uiFile:String = uiSkin.name;
		if (uiFile == null || uiFile.length < 1) {
			uiFile = 'default';
		}

		frames = Paths.getSparrowAtlas(UIData.checkImageFile('notes/$texture', uiSkin));
		animation.addByPrefix('static', 'arrow' + directions[noteData] + '0');
		animation.addByPrefix('pressed', colors[noteData] + ' press', 24, false);
		animation.addByPrefix('confirm', colors[noteData] + ' confirm', 24, false);

		antialiasing = ClientPrefs.globalAntialiasing;
		if (uiSkin.noAntialiasing) {
			antialiasing = false;
		}
		setGraphicSize(Std.int((width * noteSize) * uiSkin.scale * uiSkin.noteScale));
		updateHitbox();

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function postAddedToGroup() {
		playAnim('static');
		x += swagWidth * noteData;
		x += xOff;
		x += ((FlxG.width / 2) * player);
		ID = noteData;
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		if(animation.curAnim != null){ //my bad i was upset
			if(animation.curAnim.name == 'confirm') {
				centerOrigin();
			}
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();
		if(animation.curAnim == null || animation.curAnim.name == 'static') {
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
		} else {
			colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;

			if(animation.curAnim.name == 'confirm') {
				centerOrigin();
			}
		}
	}
}
