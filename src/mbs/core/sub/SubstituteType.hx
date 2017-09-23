package mbs.core.sub;

import haxe.ds.Vector;

import mbs.core.ComposedType;
import mbs.core.MbsType;

class SubstituteType extends ComposedType
{
	public var parentName:String;
	
	public function new(name:String, parentName:String, fields:Vector<MbsField>, size:Int)
	{
		super(name);
		this.parentName = parentName;
		this.fields = fields.toArray();
		this.size = size;
	}
	
	public function mapTypes(typeMap:Map<String, MbsType>):Void
	{
		parent = cast typeMap.get(parentName);
		
		if(fields != null)
		{
			for(i in 0...fields.length)
			{
				var f:SubstituteField = cast fields[i];
				f.type = typeMap.get(f.typeName);
			}
		}
	}
}
