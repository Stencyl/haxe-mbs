package mbs.core.header;

import mbs.core.MbsTypedefSet;

class Typedefs extends MbsTypedefSet
{
	public static var instance = new Typedefs();
	
	override public function addTypes():Void
	{
		mbs.core.header.MbsHeader.initializeType();
		types.push(mbs.core.header.MbsHeader.MBS_HEADER);
		mbs.core.header.MbsTypeInfo.initializeType();
		types.push(mbs.core.header.MbsTypeInfo.MBS_TYPE_INFO);
		mbs.core.header.MbsFieldInfo.initializeType();
		types.push(mbs.core.header.MbsFieldInfo.MBS_FIELD_INFO);
		
	}
	
	override public function getHash():Int
	{
		return -1684419011;
	}
}
