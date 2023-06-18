package;

import Section.SwagSection;
import haxe.Json;
import lime.utils.Assets;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;

	var uiSkin:String;
	var uiSkinOpponent:String;
	var validScore:Bool;

	var playerKeyAmount:Null<Int>;
	var opponentKeyAmount:Null<Int>;
	var numerator:Null<Int>;
	var denominator:Null<Int>;
}

typedef DifferentJSON =
{
	var player3:String; //Psych Engine
	var arrowSkin:String; //Psych Engine
	var mania:Null<Int>; //Shaggy
	var gf:String; //Leather Engine
	var keyCount:Null<Int>; //Leather Engine
	var playerKeyCount:Null<Int>; //Leather Engine
	var timescale:Array<Int>; //Leather Engine
	var ui_Skin:String; //Leather Engine
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;

	private static function onLoadJson(songJson:SwagSong) // Convert old charts to newest format
	{
		var songName:String = Paths.formatToSongPath(songJson.song);

		if(songJson.events == null)
		{
			songJson.events = [];
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while(i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if(note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}

		for (secNum in 0...songJson.notes.length) { //removing int note types
			var sec:SwagSection = songJson.notes[secNum];
			var i:Int = 0;
			var notes:Array<Dynamic> = sec.sectionNotes;
			var len:Int = notes.length;
			while(i < len)
			{
				var note:Array<Dynamic> = notes[i];
				var daType:String = note[3];
				if(!Std.isOfType(note[3], String) && note[3] < 6) daType = editors.ChartingState.noteTypeList[note[3]];
				sec.sectionNotes[i] = [note[0], note[1], note[2], daType];
				i++;
			}
		}

		if(songJson.playerKeyAmount == null)
		{
			songJson.playerKeyAmount = 4;
			songJson.opponentKeyAmount = 4;
		}
		if(songJson.numerator == null)
		{
			songJson.numerator = 4;
			songJson.denominator = 4;
		}

		if(songJson.notes.length > 0 && songJson.notes[0].changeSignature == null)
		{
			for (secNum in 0...songJson.notes.length)
			{
				songJson.notes[secNum].changeSignature = false;
				songJson.notes[secNum].numerator = songJson.numerator;
				songJson.notes[secNum].denominator = songJson.denominator;
			}
		}
	}

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = null;
		
		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);
		#if MODS_ALLOWED
		var moddyFile:String = Paths.modsJson(formattedFolder + '/' + formattedSong);
		if(FileSystem.exists(moddyFile)) {
			rawJson = File.getContent(moddyFile).trim();
		}
		#end

		if(rawJson == null) {
			#if sys
			rawJson = File.getContent(Paths.json(formattedFolder + '/' + formattedSong)).trim();
			#else
			rawJson = Assets.getText(Paths.json(formattedFolder + '/' + formattedSong)).trim();
			#end
		}

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		var songJson:SwagSong = parseJSONshit(rawJson);
		if(formattedSong != 'events') StageData.loadDirectory(songJson);
		onLoadJson(songJson);
		return songJson;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var tempSong:DifferentJSON = cast Json.parse(rawJson).song;
		var swagShit:SwagSong = cast Json.parse(rawJson).song;

		if(tempSong.player3 != null) {
			swagShit.gfVersion = tempSong.player3;
		}
		if(tempSong.arrowSkin != null) {
			swagShit.uiSkin = tempSong.arrowSkin;
			swagShit.uiSkinOpponent = tempSong.arrowSkin;
		}
		if (tempSong.mania != null) {
			switch (tempSong.mania) {
				case 1:
					swagShit.playerKeyAmount = 6;
				case 2:
					swagShit.playerKeyAmount = 7;
				case 3:
					swagShit.playerKeyAmount = 9;
				default:
					swagShit.playerKeyAmount = 4;
			}
			swagShit.opponentKeyAmount = swagShit.playerKeyAmount;
		}
		if(tempSong.gf != null && swagShit.gfVersion == null) {
			swagShit.gfVersion = tempSong.gf;
		}
		if (tempSong.keyCount != null) {
			swagShit.playerKeyAmount = tempSong.keyCount;
			swagShit.opponentKeyAmount = tempSong.keyCount;
		}
		if (tempSong.playerKeyCount != null) {
			swagShit.playerKeyAmount = tempSong.playerKeyCount;
		}
		if (tempSong.timescale != null && tempSong.timescale.length == 2) {
			swagShit.numerator = tempSong.timescale[0];
			swagShit.denominator = tempSong.timescale[1];
		}

		swagShit.validScore = true;
		return swagShit;
	}
}
