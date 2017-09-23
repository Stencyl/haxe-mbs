package mbs.io.read;

import mbs.core.ComposedType;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.read.MbsObjectReader;
import mbs.io.read.MbsReader;

class MbsMapReader extends MbsReaderHelper
{
	private var keyType:MbsType;
	private var valueType:MbsType;
	
	private var readAddress:Int;
	private var elementSize:Int;
	private var keySize:Int;
	
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
			keyType = reader.readTypecode(address + INTEGER.getSize());
			valueType = reader.readTypecode(address + INTEGER.getSize() + typecodeLength);
			keySize = keyType.getSize();
			
			elementSize = keyType.getSize() + valueType.getSize();
			if(valueType == DYNAMIC)
			{
				elementSize += typecodeLength;
			}
			
			readAddress = address + INTEGER.getSize() + typecodeLength * 2;
		}
		else
		{
			keyType = null;
			valueType = null;
			keySize = 0;
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
	
	public function getKeyType():MbsType
	{
		return keyType;
	}
	
	public function getValueType():MbsType
	{
		return valueType;
	}
	
	public function readStringKey():String
	{
		return reader.readString(readAddress);
	}
	
	public function readBool():Bool
	{
		var b = reader.readBool(readAddress + keySize);
		readAddress += elementSize;
		return b;
	}
	
	public function readFloat():Float
	{
		var f = reader.readFloat(readAddress + keySize);
		readAddress += elementSize;
		return f;
	}
	
	public function readInt():Int
	{
		var i = reader.readInt(readAddress + keySize);
		readAddress += elementSize;
		return i;
	}
	
	public function readString():String
	{
		var s = reader.readString(readAddress + keySize);
		readAddress += elementSize;
		return s;
	}
	
	private var dynReader:MbsDynamicReader = null;
	
	public function readDynamic():MbsDynamicReader
	{
		if(valueType != DYNAMIC)
		{
			return null;
		}
		
		if(dynReader == null)
			dynReader = new MbsDynamicReader(reader);
		dynReader.setAddress(readAddress + keySize);
		readAddress += elementSize;
		
		return dynReader;
	}
	
	private var objReader:MbsObjectReader = null;
	
	public function readObject():MbsObjectReader
	{
		if(!Std.is(valueType, ComposedType))
		{
			return null;
		}
		
		if(objReader == null)
			objReader = new MbsObjectReader(reader);
		objReader.setAddress(readAddress + keySize);
		readAddress += elementSize;
		
		return objReader;
	}
}

