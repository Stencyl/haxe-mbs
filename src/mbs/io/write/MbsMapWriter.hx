package mbs.io.write;

import mbs.core.ComposedType;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;

class MbsMapWriter extends MbsWriterHelper
{
	private var keyType:MbsType;
	private var valueType:MbsType;
	
	private var writeAddress:Int;
	private var elementSize:Int;
	
	public function new(writer:MbsWriter, keyType:MbsType, valueType:MbsType)
	{
		super(writer);
		this.keyType = keyType;
		this.valueType = valueType;
		
		elementSize = keyType.getSize() + valueType.getSize();
		if(valueType == DYNAMIC)
		{
			elementSize += writer.getTypecodeLength();
		}
	}
	
	public function allocateNew(resourceCount:Int):Int
	{
		if(resourceCount == 0)
			return 0;
		
		var typecodeLength = writer.getTypecodeLength();
		
		address = writer.allocate(INTEGER.getSize() + typecodeLength * 2 + elementSize * resourceCount);
		writer.writeInt(address, resourceCount);
		writer.writeTypecode(keyType, address + INTEGER.getSize());
		writer.writeTypecode(valueType, address + INTEGER.getSize() + typecodeLength);
		writeAddress = address + INTEGER.getSize() + typecodeLength * 2;
		
		return address;
	}

	public function writeStringKey(key:String):Void
	{
		writer.writeString(writeAddress, key);
	}
	
	public function writeBool(value:Bool):Void
	{
		writer.writeBool(writeAddress, value);
		writeAddress += elementSize;
	}
	
	public function writeFloat(value:Float):Void
	{
		writer.writeFloat(writeAddress, value);
		writeAddress += elementSize;
	}
	
	public function writeInt(value:Int):Void
	{
		writer.writeInt(writeAddress, value);
		writeAddress += elementSize;
	}
	
	public function writeString(value:String):Void
	{
		writer.writeString(writeAddress, value);
		writeAddress += elementSize;
	}

	private var dynWriter:MbsDynamicWriter;
	
	public function writeDynamic():MbsDynamicWriter
	{
		if(valueType != DYNAMIC)
		{
			return null;
		}
		
		if(dynWriter == null)
			dynWriter = new MbsDynamicWriter(writer);
		dynWriter.setAddress(writeAddress);
		writeAddress += elementSize;
		
		return dynWriter;
	}
	
	private var objWriter:MbsObjectWriter;
	
	public function writeObject():MbsObjectWriter
	{
		if(!Std.is(valueType, ComposedType))
		{
			return null;
		}
		
		if(objWriter == null)
			objWriter = new MbsObjectWriter(writer, cast valueType);
		objWriter.setAddress(writeAddress);
		writeAddress += elementSize;
		
		return objWriter;
	}
}
