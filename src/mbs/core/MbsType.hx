package mbs.core;

class MbsType
{
	@:allow(mbs.core)
	private var name:String;
	@:allow(mbs.core)
	private var size:Int;

	public function new(name:String, size:Int) 
	{
		this.name = name;
		this.size = size;
	}

	public function getName():String 
	{
		return name;
	}

	public function getSize():Int 
	{
		return size;
	}

	public function toString():String
	{
		return "MbsType [name=" + getName() + "]";
	}
}

