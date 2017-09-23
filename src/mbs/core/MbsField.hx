package mbs.core;

class MbsField
{
	private var name:String;
	public var type:MbsType;
	public var address:Int;

	public function new(name:String, type:MbsType, address:Int) 
	{
		this.name = name;
		this.type = type;
		this.address = address;
	}

	public function getName():String 
	{
		return name;
	}

	public function getType():MbsType 
	{
		return type;
	}

	public function getAddress():Int 
	{
		return address;
	}
}