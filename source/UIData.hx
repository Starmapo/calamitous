package;

import haxe.Json;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#else
import lime.utils.Assets;
#end

using StringTools;

typedef SkinFile = {
    var name:String; //just internal name to make it easier
	var mania:Array<ManiaArray>; //data for key amounts
    var scale:Float; //overall scale (all other scales are added ontop of this one)
    var noteScale:Float; //note scale (added ontop the mania one)
    var sustainYScale:Float; //sustain note y scale
    var countdownScale:Float; //countdown sprites scale
    var ratingScale:Float; //rating and 'combo' sprites scale
    var comboNumScale:Float; //combo numbers scale
    var sustainXOffset:Float; //sustain note x offset
    var tailYOffset:Float; //sustain tail note y offset for downscroll
    var noAntialiasing:Bool; //whether to always have antialiasing disabled
}

typedef ManiaArray = {
    var keys:Int; //key amount to be attached to
    var noteSize:Float; //note scale
    var noteSpacing:Float; //spacing between each note
    var xOffset:Float; //extra offset for the strums
    var colors:Array<String>; //name order for the colors
    var directions:Array<String>; //name order for the strum directions
    var singAnimations:Array<String>; //name order for the sing animations
}

class UIData {
    public static function getUIFile(skin:String):SkinFile {
        if (skin == null || skin.length < 1) skin = 'default';
        var daFile:SkinFile = null;
        var rawJson:String = null;
        var path:String = Paths.getPreloadPath('images/uiskins/' + skin + '.json');
    
        #if MODS_ALLOWED
        var modPath:String = Paths.modFolders('images/uiskins/' + skin + '.json');
        if(FileSystem.exists(modPath)) {
            rawJson = File.getContent(modPath);
        } else if(FileSystem.exists(path)) {
            rawJson = File.getContent(path);
        }
        #else
        if(Assets.exists(path)) {
            rawJson = Assets.getText(path);
        }
        #end
        else
        {
            return null;
        }
        daFile = cast Json.parse(rawJson);
        daFile.name = skin;
        return daFile;
    }

    public static function checkImageFile(file:String, uiSkin:SkinFile) {
        var path:String = 'uiskins/${uiSkin.name}/$file';
		#if MODS_ALLOWED
		if (!FileSystem.exists(Paths.getPath('images/$path.png', IMAGE)) && !FileSystem.exists(Paths.modFolders('images/$path.png'))) {
		#else
		if (!Assets.exists(Paths.getPath('images/$path.png', IMAGE))) {
		#end
			path = 'uiskins/default/$file';
		}
        return path;
    }
}