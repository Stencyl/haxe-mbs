package mbs.core.reflect;

import haxe.ds.Vector;
import mbs.core.reflect.*;
import mbs.core.MbsObject;
import mbs.core.MbsTypes.*;
import mbs.io.MbsListBase;
import mbs.io.MbsGenericObject;
import mbs.io.MbsReader;

class ReflectionReader extends MbsReader
{
	public function new(typedefSet:MbsTypedefSet, readStoredTypeInformation:Bool)
	{
		super(typedefSet, readStoredTypeInformation);
	}

	public function traceInfo()
	{
		trace("TYPES:");
		trace(typeTable);
		trace("");
		
		trace("STRINGS:");
		trace(stringTable);
		trace("");

		trace("ROOT:");
		trace(getRoot());
	}

	public function getReflectedRoot():Dynamic
	{
		var root = header.getRoot();

		if(Std.is(root, MbsListBase))
		{
			var ml:MbsListBase = cast root;
			return readList(ml.getAddress());
		}
		else if(Std.is(root, MbsObject))
		{
			var mo:MbsObject = cast root;
			return readObject(mo.getMbsType(), mo.getAddress());
		}
		else
		{
			return root;
		}
	}

	private function readObject(type:MbsType, address:Int):SubstituteObject
	{
		var obj = new SubstituteObject();
		var st:ComposedType = cast type;
		
		var fields = new Array<MbsField>();
		while(st != null)
		{
			if(st.getFields() != null)
				fields = fields.concat(st.getFields());
			st = st.getParent();
		}
		
		var genObj = new MbsGenericObject(this, type);
		genObj.setAddress(address);
		for(f in fields)
		{
			obj.set(f.getName(), readField(genObj, f));
		}
		
		return obj;
	}

	private function readField(r:MbsGenericObject, f:MbsField):Dynamic
	{
		return switch(f.type.getName())
		{
			case "boolean": r.readBool(f);
			case "integer": r.readInt(f);
			case "float": r.readFloat(f);
			case "string": r.readString(f);
			case "list": readList(r.readInt(f));
			case "dynamic": readDynamic(r.getAddress() + f.address);
			default: readObject(f.type, r.getAddress() + f.address);
		}
	}

	private function readList(address:Int):Vector<Dynamic>
	{
		if(address == 0)
			return new Vector<Dynamic>(0);
		
		var length = readInt(address);
		var list = new Vector<Dynamic>(length);
		var type = readTypecode(address + INTEGER.getSize());

		var readAddress = address + INTEGER.getSize() * 2;
		for(i in 0...length)
		{
			switch(type.getName())
			{
				case "boolean": list[i] = readBool(readAddress);
				case "integer": list[i] = readInt(readAddress);
				case "float": list[i] = readFloat(readAddress);
				case "string": list[i] = readString(readAddress);
				case "dynamic": list[i] = readDynamic(readAddress);
				default: list[i] = readObject(type, readAddress);
			}
			readAddress += type.getSize();
		}
		return list;
	}

	private function readDynamic(address:Int):Dynamic
	{
		var type = readTypecode(address);

		return switch(type.getName())
		{
			case "boolean": readBool(address + INTEGER.getSize());
			case "integer": readInt(address + INTEGER.getSize());
			case "float": readFloat(address + INTEGER.getSize());
			case "string": readString(address + INTEGER.getSize());
			case "list": readList(readInt(address + INTEGER.getSize()));
			case "dynamic": readDynamic(readInt(address + INTEGER.getSize()));
			default: readObject(type, readInt(address + INTEGER.getSize()));
		};
	}
}