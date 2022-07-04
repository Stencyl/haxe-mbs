package mbs.io;

import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;

class MbsListBase extends MbsObject
{
	private var type:MbsType;
	
	@:allow(mbs.io) private var elementAddress:Int;
	@:allow(mbs.io) private var elementSize:Int;
	private var _length:Int;
	
	public function new(data:MbsIO, type:MbsType)
	{
		super(data);
		if(type != null)
		{
			this.type = type;
			elementSize = type.getSize();
		}
	}
	
	override public function setAddress(address:Int):Void
	{
		super.setAddress(address);
		
		if(data.isReader())
		{
			if(address != 0)
			{
				_length = data.readInt(address);
				type = data.readTypecode(address + INTEGER.getSize());
				
				elementSize = type.getSize();
				elementAddress = address + INTEGER.getSize() * 2;
			}
			else
			{
				type = null;
				_length = 0;
				elementSize = 0;
				elementAddress = 0;
			}
		}
	}
	
	public function allocateNew(length:Int):Int
	{
		if(data.isWriter())
		{
			_length = length;
			
			address = data.allocate(INTEGER.getSize() * 2 + elementSize * length);
			data.writeInt(address, length);
			data.writeTypecode(address + INTEGER.getSize(), type);
			elementAddress = address + INTEGER.getSize() * 2;
			
			return address;
		}
		else
		{
			throw "Can't allocate new objects when reading";
		}
	}
	
	public function length():Int
	{
		return _length;
	}

	override public function getMbsType():MbsType
	{
		return LIST;
	}
}

class MbsBoolList extends MbsListBase
{
	public function new(data:MbsIO)
	{
		super(data, BOOLEAN);
	}

	public function readBool():Bool
	{
		var b = data.readBool(elementAddress);
		elementAddress += elementSize;
		return b;
	}
	
	public function writeBool(value:Bool):Void
	{
		data.writeBool(elementAddress, value);
		elementAddress += elementSize;
	}
}

class MbsFloatList extends MbsListBase
{
	public function new(data:MbsIO)
	{
		super(data, FLOAT);
	}

	public function readFloat():Float
	{
		var f = data.readFloat(elementAddress);
		elementAddress += elementSize;
		return f;
	}
	
	public function writeFloat(value:Float):Void
	{
		data.writeFloat(elementAddress, value);
		elementAddress += elementSize;
	}
}

class MbsIntList extends MbsListBase
{
	public function new(data:MbsIO)
	{
		super(data, INTEGER);
	}
	
	public function readInt():Int
	{
		var i = data.readInt(elementAddress);
		elementAddress += elementSize;
		return i;
	}
	
	public function writeInt(value:Int):Void
	{
		data.writeInt(elementAddress, value);
		elementAddress += elementSize;
	}
}

class MbsStringList extends MbsListBase
{
	public function new(data:MbsIO)
	{
		super(data, STRING);
	}
	
	public function readString():String
	{
		var s = data.readString(elementAddress);
		elementAddress += elementSize;
		return s;
	}
	
	public function writeString(value:String):Void
	{
		data.writeString(elementAddress, value);
		elementAddress += elementSize;
	}
}

class MbsDynamicList extends MbsListBase
{
	public function new(data:MbsIO)
	{
		super(data, DYNAMIC);
	}

	public function readObject():Dynamic
	{
		var obj = MbsDynamicHelper.readDynamic(data, elementAddress);
		elementAddress += elementSize;
		return obj;
	}

	public function readObjectUsingPool(pool:MbsDynamicHelper.DynamicPool):Dynamic
	{
		var obj = MbsDynamicHelper.readDynamicUsingPool(data, elementAddress, pool);
		elementAddress += elementSize;
		return obj;
	}
	
	public function writeObject(o:Dynamic):Void
	{
		MbsDynamicHelper.writeDynamic(data, elementAddress, o);
		elementAddress += elementSize;
	}
}