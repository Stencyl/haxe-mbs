package mbs.core;

import mbs.io.MbsIO;

class MbsObject
{
	@:allow(mbs.core,mbs.io) private var data:MbsIO;
	@:allow(mbs.core,mbs.io) private var address:Int;
	
	private function new(data:MbsIO)
	{
		this.data = data;
	}
	
	public function getMbs():MbsIO
	{
		return data;
	}
	
	public function getAddress():Int
	{
		return address;
	}

	public function setAddress(address:Int):Void
	{
		this.address = address;
	}

	public function getMbsType():MbsType
	{
		throw "Must override getMbsType in MbsObject subclasses";
	}
}
