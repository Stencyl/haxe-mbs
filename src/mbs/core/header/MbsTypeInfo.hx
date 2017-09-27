package mbs.core.header;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsTypeInfo extends MbsObject
{
	public static var name:MbsField;
	public static var parent:MbsField;
	public static var fieldsPointer:MbsField;
	public static var size:MbsField;
	
	public static var MBS_TYPE_INFO:ComposedType;
	public static function initializeFields():Void
	{
		MBS_TYPE_INFO = new ComposedType("MbsTypeInfo");
		MBS_TYPE_INFO.setInstantiator(function(data) return new MbsTypeInfo(data));
		
		name = MBS_TYPE_INFO.createField("name", STRING);
		parent = MBS_TYPE_INFO.createField("parent", STRING);
		fieldsPointer = MBS_TYPE_INFO.createField("fieldsPointer", INTEGER);
		size = MBS_TYPE_INFO.createField("size", INTEGER);
		
	}
	
	public static function new_MbsTypeInfo_list(data:MbsIO):MbsList<MbsTypeInfo>
	{
		return new MbsList<MbsTypeInfo>(data, MBS_TYPE_INFO, new MbsTypeInfo(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_TYPE_INFO;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_TYPE_INFO.getSize()));
	}
	
	public function getName():String
	{
		return data.readString(address + name.address);
	}
	
	public function setName(_val:String):Void
	{
		data.writeString(address + name.address, _val);
	}
	
	public function getParent():String
	{
		return data.readString(address + parent.address);
	}
	
	public function setParent(_val:String):Void
	{
		data.writeString(address + parent.address, _val);
	}
	
	public function getFieldsPointer():Int
	{
		return data.readInt(address + fieldsPointer.address);
	}
	
	public function setFieldsPointer(_val:Int):Void
	{
		data.writeInt(address + fieldsPointer.address, _val);
	}
	
	public function getSize():Int
	{
		return data.readInt(address + size.address);
	}
	
	public function setSize(_val:Int):Void
	{
		data.writeInt(address + size.address, _val);
	}
	
}
