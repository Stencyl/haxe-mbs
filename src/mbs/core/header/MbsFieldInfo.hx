package mbs.core.header;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsFieldInfo extends MbsObject
{
	public static var name:MbsField;
	public static var type:MbsField;
	public static var fieldAddress:MbsField;
	
	public static var MBS_FIELD_INFO:ComposedType;
	public static function initializeFields():Void
	{
		MBS_FIELD_INFO = new ComposedType("MbsFieldInfo");
		MBS_FIELD_INFO.setInstantiator(function(data) return new MbsFieldInfo(data));
		
		name = MBS_FIELD_INFO.createField("name", STRING);
		type = MBS_FIELD_INFO.createField("type", STRING);
		fieldAddress = MBS_FIELD_INFO.createField("fieldAddress", INTEGER);
		
	}
	
	public static function new_MbsFieldInfo_list(data:MbsIO):MbsList<MbsFieldInfo>
	{
		return new MbsList<MbsFieldInfo>(data, MBS_FIELD_INFO, new MbsFieldInfo(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_FIELD_INFO;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_FIELD_INFO.getSize()));
	}
	
	public function getName():String
	{
		return data.readString(address + name.address);
	}
	
	public function setName(_val:String):Void
	{
		data.writeString(address + name.address, _val);
	}
	
	public function getType():String
	{
		return data.readString(address + type.address);
	}
	
	public function setType(_val:String):Void
	{
		data.writeString(address + type.address, _val);
	}
	
	public function getFieldAddress():Int
	{
		return data.readInt(address + fieldAddress.address);
	}
	
	public function setFieldAddress(_val:Int):Void
	{
		data.writeInt(address + fieldAddress.address, _val);
	}
	
}
