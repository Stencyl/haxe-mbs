package mbs.core;

import mbs.io.MbsIO;
import mbs.io.MbsList;

class ComposedType extends MbsType
{
	@:allow(mbs.core)
	private var parent:ComposedType;
	@:allow(mbs.core)
	private var fields:Array<MbsField>;

	public function new(name:String)
	{
		super(name, 0);
		fields = new Array<MbsField>();
	}
	
	public function inherit(type:ComposedType):Void
	{
		parent = type;
		size = type.getSize();
	}
	
	public function createField(name:String, type:MbsType):MbsField
	{
		var newField = new MbsField(name, type, size);
		fields.push(newField);
		size += type.getSize();
		return newField;
	}

	public function getParent():ComposedType
	{
		return parent;
	}

	public function getFields():Array<MbsField>
	{
		return fields;
	}

	private var instantiator:MbsIO->MbsObject;
	
	public function setInstantiator(instantiator:MbsIO->MbsObject)
	{
		this.instantiator = instantiator;
	}
	
	override public function createInstance(data:MbsIO):MbsObject
	{
		if(instantiator != null)
			return instantiator(data);
		else
			return super.createInstance(data);
	}
	
	public function createList<V:MbsObject>(data:MbsIO):MbsList<V>
	{
		return new MbsList<V>(data, this, cast createInstance(data));
	}
}