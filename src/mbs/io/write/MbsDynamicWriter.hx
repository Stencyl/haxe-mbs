package mbs.io.write;

import mbs.core.ComposedType;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;

class MbsDynamicWriter extends MbsWriterHelper
{
	private var typecodeLength:Int;
	
	public function new(writer:MbsWriter)
	{
		super(writer);
		typecodeLength = writer.getTypecodeLength();
	}
	
	public function setAddress(int address):Void
	{
		this.address = address;
	}
	
	public function allocateNew():Int
	{
		return address = writer.allocate(DYNAMIC.getSize() + typecodeLength);
	}

	public function writeBool(value:Bool):Void
	{
		writer.writeTypecode(BOOLEAN, address);
		writer.writeBool(address + typecodeLength, value);
	}
	
	public function writeFloat(value:Float):Void
	{
		writer.writeTypecode(FLOAT, address);
		writer.writeFloat(address + typecodeLength, value);
	}
	
	public function writeInt(value:Int):Void
	{
		writer.writeTypecode(INTEGER, address);
		writer.writeInt(address + typecodeLength, value);
	}
	
	public function writeString(value:String):Void
	{
		writer.writeTypecode(STRING, address);
		writer.writeString(address + typecodeLength, value);
	}
	
	public function writeObject(type:ComposedType):MbsObjectWriter
	{
		writer.writeTypecode(type, address);
		var obj = new MbsObjectWriter(writer, type);
		obj.allocateNew();
		writer.writeInt(address + typecodeLength, obj.getAddress());
		return obj;
	}
	
	public function writeList(type:MbsType, length:Int):MbsListWriter
	{
		writer.writeTypecode(LIST, address);
		var list = new MbsListWriter(writer, type);
		list.allocateNew(length);
		writer.writeInt(address + typecodeLength, list.getAddress());
		return list;
	}
	
	public function writeMap(keyType:MbsType, valueType:MbsType, length:Int):MbsMapWriter
	{
		writer.writeTypecode(MAP, address);
		var map = new MbsMapWriter(writer, keyType, valueType);
		map.allocateNew(length);
		writer.writeInt(address + typecodeLength, map.getAddress());
		return map;
	}
}
