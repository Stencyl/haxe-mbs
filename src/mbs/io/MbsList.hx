package mbs.io;

import mbs.core.MbsObject;
import mbs.core.MbsType;

class MbsList<T:MbsObject> extends MbsListBase
{
	private var obj:T;
	
	public function new(data:MbsIO, type:MbsType, _obj:T)
	{
		super(data, type);
	}
	
	public function getNextObject():T
	{
		obj.setAddress(elementAddress);
		elementAddress += elementSize;
		return obj;
	}
}
