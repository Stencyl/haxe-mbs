package mbs.io.read;

import mbs.core.ComposedType;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;

class MbsListReader extends MbsReaderHelper
{
	private var type:MbsType;
	
	private var readAddress:Int;
	private var elementSize:Int;
	
	public function new(reader:MbsReader)
	{
		super(reader);
	}

	override public function setAddress(address:Int):Void
	{
		super.setAddress(address);
		
		if(address != 0)
		{
			var typecodeLength = reader.getTypecodeLength();
			type = reader.readTypecode(address + INTEGER.getSize());
			
			elementSize = type.getSize();
			if(type == DYNAMIC)
			{
				elementSize += typecodeLength;
			}
			
			readAddress = address + INTEGER.getSize() + typecodeLength;
		}
		else
		{
			type = null;
			elementSize = 0;
			readAddress = 0;
		}
	}
	
	public function length():Int
	{
		if(address == 0)
			return 0;
		
		return reader.readInt(address);
	}
	
	public function getType():MbsType
	{
		return type;
	}
	
	public function readBool():Bool
	{
		var b = reader.readBool(readAddress);
		readAddress += elementSize;
		return b;
	}
	
	public function readFloat():Float
	{
		var f = reader.readFloat(readAddress);
		readAddress += elementSize;
		return f;
	}
	
	public function readInt():Int
	{
		var i = reader.readInt(readAddress);
		readAddress += elementSize;
		return i;
	}
	
	public function readString():String
	{
		var s = reader.readString(readAddress);
		readAddress += elementSize;
		return s;
	}
	
	private var dynReader:MbsDynamicReader = null;
	
	public function readDynamic():MbsDynamicReader
	{
		if(type != DYNAMIC)
		{
			return null;
		}
		
		if(dynReader == null)
			dynReader = new MbsDynamicReader(reader);
		dynReader.setAddress(readAddress);
		readAddress += elementSize;
		
		return dynReader;
	}
	
	private var objReader:MbsObjectReader = null;
	
	public function readObject():MbsObjectReader
	{
		if(!Std.is(type, ComposedType))
		{
			return null;
		}
		
		if(objReader == null)
			objReader = new MbsObjectReader(reader);
		objReader.setAddress(readAddress);
		readAddress += elementSize;
		
		return objReader;
	}
}

