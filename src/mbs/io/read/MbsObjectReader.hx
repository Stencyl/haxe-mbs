package mbs.io.read;

import mbs.core.MbsField;

class MbsObjectReader extends MbsReaderHelper
{
	public function new(reader:MbsReader)
	{
		super(reader);
	}
	
	public function readBool(field:MbsField):Bool
	{
		return reader.readBool(address + field.address);
	}
	
	public function readFloat(field:MbsField):Float
	{
		return reader.readFloat(address + field.address);
	}
	
	public function readInt(field:MbsField):Int
	{
		return reader.readInt(address + field.address);
	}
	
	public function readString(field:MbsField):String
	{
		return reader.readString(address + field.address);
	}
	
	public function readObject(field:MbsField):MbsObjectReader
	{
		var objReader = new MbsObjectReader(reader);
		objReader.setAddress(address + field.address);
		return objReader;
	}
	
	public function readDynamic(field:MbsField):MbsDynamicReader
	{
		var dynReader = new MbsDynamicReader(reader);
		dynReader.setAddress(readInt(field));
		return dynReader;
	}
	
	public function readList(field:MbsField):MbsListReader
	{
		var listReader = new MbsListReader(reader);
		listReader.setAddress(readInt(field));
		return listReader;
	}
	
	public function readMap(field:MbsField):MbsMapReader
	{
		var mapReader = new MbsMapReader(reader);
		mapReader.setAddress(readInt(field));
		return mapReader;
	}
}

