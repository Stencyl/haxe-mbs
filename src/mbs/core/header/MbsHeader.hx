package mbs.core.header;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsDynamicHelper;
import mbs.io.MbsIO;
import mbs.io.MbsList;

class MbsHeader extends MbsObject
{
	public static var typeTablePointer:MbsField;
	public static var stringTablePointer:MbsField;
	public static var root:MbsField;
	
	public static var MBS_HEADER:ComposedType;
	public static function initializeFields():Void
	{
		MBS_HEADER = new ComposedType("MbsHeader");
		MBS_HEADER.setInstantiator(function(data) return new MbsHeader(data));
		
		typeTablePointer = MBS_HEADER.createField("typeTablePointer", INTEGER);
		stringTablePointer = MBS_HEADER.createField("stringTablePointer", INTEGER);
		root = MBS_HEADER.createField("root", DYNAMIC);
		
	}
	
	public static function new_MbsHeader_list(data:MbsIO):MbsList<MbsHeader>
	{
		return new MbsList<MbsHeader>(data, MBS_HEADER, new MbsHeader(data));
	}
	
	override public function getMbsType():MbsType
	{
		return MBS_HEADER;
	}
	
	public function new(data:MbsIO)
	{
		super(data);
	}
	
	public function allocateNew():Void
	{
		setAddress(data.allocate(MBS_HEADER.getSize()));
	}
	
	public function getTypeTablePointer():Int
	{
		return data.readInt(address + typeTablePointer.address);
	}
	
	public function setTypeTablePointer(_val:Int):Void
	{
		data.writeInt(address + typeTablePointer.address, _val);
	}
	
	public function getStringTablePointer():Int
	{
		return data.readInt(address + stringTablePointer.address);
	}
	
	public function setStringTablePointer(_val:Int):Void
	{
		data.writeInt(address + stringTablePointer.address, _val);
	}
	
	public function getRoot():Dynamic
	{
		return MbsDynamicHelper.readDynamic(data, address + root.address);
	}
	
	public function setRoot(_val:Dynamic):Void
	{
		MbsDynamicHelper.writeDynamic(data, address + root.address, _val);
	}
	
}
