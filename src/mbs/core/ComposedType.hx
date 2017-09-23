package mbs.core;

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
		var fieldPos = size;
		var newField = new MbsField(name, type, fieldPos);
		
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
}

