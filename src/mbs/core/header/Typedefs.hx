package mbs.core.header;

import mbs.core.MbsTypedefSet;

class Typedefs extends MbsTypedefSet
{
	public static var instance = new Typedefs();
	
	override public function addTypes():Void
	{
		types.push(mbs.core.header.MbsHeader.MBS_HEADER);
		types.push(mbs.core.header.MbsTypeInfo.MBS_TYPE_INFO);
		types.push(mbs.core.header.MbsFieldInfo.MBS_FIELD_INFO);
		
	}
}
