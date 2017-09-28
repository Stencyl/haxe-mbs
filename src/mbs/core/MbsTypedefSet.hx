package mbs.core;

import mbs.core.header.MbsFieldInfo;
import mbs.core.header.MbsHeader;
import mbs.core.header.MbsTypeInfo;
import mbs.core.MbsTypes.*;

class MbsTypedefSet
{
	public static function getBasicTypes():Array<MbsType>
	{
		var types = new Array<MbsType>();
		
		types.push(BOOLEAN);
		types.push(INTEGER);
		types.push(FLOAT);
		types.push(STRING);
		types.push(LIST);
		types.push(DYNAMIC);
		types.push(MbsHeader.MBS_HEADER);
		types.push(MbsTypeInfo.MBS_TYPE_INFO);
		types.push(MbsFieldInfo.MBS_FIELD_INFO);
		
		return types;
	}
	
	public var types:Array<MbsType>;
	public var typecodes:Map<MbsType, Int>;
	
	private function new()
	{
		types = MbsTypedefSet.getBasicTypes().copy();
		typecodes = new Map<MbsType,Int>();
		addTypes();
		
		var counter = 0;
		for(type in types)
		{
			typecodes.set(type, counter++);
		}
	}
	
	public function getTypes():Array<MbsType>
	{
		return types;
	}

	public function addTypes():Void
	{
	}

	public function getTypecode(type:MbsType):Int
	{
		return typecodes.get(type);
	}

	public function getType(typecode:Int):MbsType
	{
		return types[typecode];
	}
}
