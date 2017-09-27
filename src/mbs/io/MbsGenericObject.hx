package mbs.io;

import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;

class MbsGenericObject extends MbsObject
{
	var type:MbsType;
	
	public function new(data:MbsIO, type:MbsType)
	{
		super(data);
		this.type = type;
	}
	
	public function allocateNew():Int
	{
		return address = data.allocate(type.getSize());
	}
	
	public function readBool(field:MbsField):Bool
	{
		return data.readBool(address + field.address);
	}
	
	public function writeBool(field:MbsField, value:Bool):Void
	{
		data.writeBool(address + field.address, value);
	}
	
	public function readFloat(field:MbsField):Float
	{
		return data.readFloat(address + field.address);
	}
	
	public function writeFloat(field:MbsField, value:Float):Void
	{
		data.writeFloat(address + field.address, value);
	}
	
	public function readInt(field:MbsField):Int
	{
		return data.readInt(address + field.address);
	}
	
	public function writeInt(field:MbsField, value:Int):Void
	{
		data.writeInt(address + field.address, value);
	}
	
	public function readString(field:MbsField):String
	{
		return data.readString(address + field.address);
	}
	
	public function writeString(field:MbsField, value:String):Void
	{
		data.writeString(address + field.address, value);
	}
	
	/**
	 * For embedded objects
	 */
	public function prepareObject(field:MbsField, helper:MbsObject):Void
	{
		helper.setAddress(address + field.address);
	}
	
	/**
	 * For linked objects
	 */
	public function readObject(field:MbsField, helper:MbsObject):Void
	{
		helper.setAddress(data.readInt(address + field.address));
	}
}
