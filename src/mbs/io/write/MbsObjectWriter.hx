package mbs.io.write;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;

class MbsObjectWriter extends MbsWriterHelper
{
	private var type:ComposedType;
	
	public function new(writer:MbsWriter, type:ComposedType)
	{
		super(writer);
		this.type = type;
	}
	
	public function setAddress(address:Int):Void
	{
		this.address = address;
	}

	public function allocateNew():Int
	{
		return address = writer.allocate(type.getSize());
	}

	public function writeBool(field:MbsField, value:Bool):Void
	{
		writer.writeBool(address + field.address, value);
	}
	
	public function writeFloat(field:MbsField, value:Float):Void
	{
		writer.writeFloat(address + field.address, value);
	}
	
	public function writeInt(field:MbsField, value:Int):Void
	{
		writer.writeInt(address + field.address, value);
	}
	
	public function writeString(field:MbsField, value:String):Void
	{
		writer.writeString(address + field.address, value);
	}
	
	public function writeDynamic(field:MbsField):MbsDynamicWriter
	{
		var dyn = new MbsDynamicWriter(writer);
		dyn.allocateNew();
		writer.writeInt(address + field.address, dyn.getAddress());
		return dyn;
	}
	
	public function writeObject(field:MbsField, type:ComposedType):MbsObjectWriter
	{
		var obj = new MbsObjectWriter(writer, type);
		obj.setAddress(address + field.address);
		return obj;
	}
	
	public function writeList(field:MbsField, type:MbsType, length:Int):MbsListWriter
	{
		var listWriter = new MbsListWriter(writer, type);
		listWriter.allocateNew(length);
		writer.writeInt(address + field.address, listWriter.getAddress());
		return listWriter;
	}
	
	public function writeMap(field:MbsField, keyType:MbsType, valueType:MbsType, length:Int):MbsMapWriter
	{
		var mapWriter = new MbsMapWriter(writer, keyType, valueType);
		mapWriter.allocateNew(length);
		writer.writeInt(address + field.address, mapWriter.getAddress());
		return mapWriter;
	}
}
