package mbs.io;

import mbs.core.MbsType;

interface MbsIO
{
	function readBool(address:Int):Bool;

	function readFloat(address:Int):Float;

	function readInt(address:Int):Int;
	
	function readString(address:Int):String;

	function writeInt(address:Int, value:Int):Void;

	function writeBool(address:Int, value:Bool):Void;

	function writeFloat(address:Int, value:Float):Void;
	
	function writeString(address:Int, value:String):Void;

	function isReader():Bool;
	
	function isWriter():Bool;
	
	function allocate(size:Int):Int;
	
	function writeTypecode(address:Int, type:MbsType):Void;
	
	function readTypecode(address:Int):MbsType;
}