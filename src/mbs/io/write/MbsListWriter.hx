package mbs.io.write;

import mbs.core.ComposedType;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;

class MbsListWriter extends MbsWriterHelper
{
	private var type:MbsType;
	
	private var writeAddress:Int;
	private var elementSize:Int;
	
	public function new(writer:MbsWriter, type:MbsType)
	{
		super(writer);
		this.type = type;
		
		elementSize = type.getSize();
		if(type == DYNAMIC)
		{
			elementSize += writer.getTypecodeLength();
		}
	}
	
	public function allocateNew(resourceCount:Int):Int
	{
		if(resourceCount == 0)
			return 0;
		
		var typecodeLength = writer.getTypecodeLength();
		
		address = writer.allocate(INTEGER.getSize() + typecodeLength + elementSize * resourceCount);
		writer.writeInt(address, resourceCount);
		writer.writeTypecode(type, address + INTEGER.getSize());
		writeAddress = address + INTEGER.getSize() + typecodeLength;
		
		return address;
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
		if(type != DYNAMIC)
		{
			return null;
		}
		
		if(dynWriter == null)
			dynWriter = new MbsDynamicWriter(writer);
		dynWriter.setAddress(writeAddress);
		writeAddress += elementSize;
		
		return dynWriter;
	}
	
	private var objWriter:MbsObjectWriter = null;
	
	public function writeObject():MbsObjectWriter
	{
		if(!Std.is(type, ComposedType))
		{
			return null;
		}
		
		if(objWriter == null)
			objWriter = new MbsObjectWriter(writer, cast type);
		objWriter.setAddress(writeAddress);
		writeAddress += elementSize;
		
		return objWriter;
	}
}
