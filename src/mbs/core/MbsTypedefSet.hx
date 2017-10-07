package mbs.core;

import mbs.core.MbsTypes.*;

class MbsTypedefSet
{
	public static var basicTypes = {

		var types = new Array<MbsType>();

		types.push(BOOLEAN);
		types.push(INTEGER);
		types.push(FLOAT);
		types.push(STRING);
		types.push(LIST);
		types.push(DYNAMIC);
		
		mbs.core.header.MbsHeader.initializeType();
		mbs.core.header.MbsTypeInfo.initializeType();
		mbs.core.header.MbsFieldInfo.initializeType();
		
		types.push(mbs.core.header.MbsHeader.MBS_HEADER);
		types.push(mbs.core.header.MbsTypeInfo.MBS_TYPE_INFO);
		types.push(mbs.core.header.MbsFieldInfo.MBS_FIELD_INFO);
		
		types;
	};
		
	public var types:Array<MbsType>;
	public var typecodes:Map<MbsType, Int>;
	
	private function new()
	{
		types = basicTypes.copy();
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

	public function getHash():Int
	{
		return 0;
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
