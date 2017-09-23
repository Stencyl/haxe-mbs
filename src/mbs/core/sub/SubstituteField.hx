package mbs.core.sub;

import mbs.core.MbsField;

class SubstituteField extends MbsField
{
	public var typeName:String;
	
	public function new(name:String, typeName:String, address:Int)
	{
		super(name, null, address);
		this.typeName = typeName;
	}

	public function toString():String
	{
		return "MbsField [name=" + getName() + ", typeName=" + typeName + ", address=" + address + "]";
	}
}
