package mbs.io;

import haxe.io.Bytes;
import haxe.io.FPHelper;
import haxe.ds.Vector;

import mbs.core.header.MbsFieldInfo;
import mbs.core.header.MbsHeader;
import mbs.core.header.MbsTypeInfo;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.core.sub.SubstituteField;
import mbs.core.sub.SubstituteObject;
import mbs.core.sub.SubstituteType;

class MbsReader implements MbsIO
{
	private var data:Bytes;

	private var stringTable:Vector<String>;
	private var typeTable:Vector<MbsType>;
	private var rootAddress:Int;

	private var subTypeMap:Map<String, MbsType>;

	private var header:MbsHeader;

	public function new(data:Bytes) 
	{
		this.data = data;
		genObj = new MbsGenericObject(this, null);
		readData();
	}

	public function readData():Void 
	{
		header = new MbsHeader(this);
		header.setAddress(0);
		
		var typeInfo = new MbsTypeInfo(this);
		var intSize = INTEGER.getSize();
		
		var readAddress = header.getStringTablePointer();
		stringTable = new Vector<String>(readInt(readAddress));
		readAddress += intSize;
		for(i in 0...stringTable.length) 
		{
			var pos = readInt(readAddress);
			var length = readInt(pos);
			stringTable[i] = data.getString(pos + 4, length);
			readAddress += intSize;
		}

		readAddress = header.getTypeTablePointer();
		typeTable = new Vector<MbsType>(readInt(readAddress));
		readAddress += intSize;
		
		subTypeMap = new Map<String, MbsType>();
		var primTypeMap = [for(type in [BOOLEAN, INTEGER, FLOAT, STRING, DYNAMIC, LIST]) type.getName() => type];
		
		for(i in 0...typeTable.length) 
		{
			typeInfo.setAddress(readInt(readAddress));
			readAddress += intSize;

			var name = typeInfo.getName();
			var parentType = typeInfo.getParent();
			var size = typeInfo.getSize();
			var fields:Vector<MbsField> = null;

			var fieldListAddress = typeInfo.getFieldsPointer();
			if(fieldListAddress != 0)
			{
				var fieldListLength = readInt(fieldListAddress);
				fieldListAddress += intSize;
				
				fields = new Vector<MbsField>(fieldListLength);
				var fieldInfo = new MbsFieldInfo(this);
				
				for(j in 0...fieldListLength)
				{
					fieldInfo.setAddress(fieldListAddress);
					fieldListAddress += MbsFieldInfo.MBS_FIELD_INFO.getSize();
					
					var fieldName = fieldInfo.getName();
					var fieldType = fieldInfo.getType();
					var fieldAddress = fieldInfo.getFieldAddress();
					
					fields[j] = new SubstituteField(fieldName, fieldType, fieldAddress);
				}
			}

			if(primTypeMap.exists(name))
			{
				typeTable[i] = primTypeMap.get(name);
			}
			else
			{
				typeTable[i] = new SubstituteType(name, parentType, fields, size);
			}
			subTypeMap.set(name, typeTable[i]);
		}
		
		for(i in 0...typeTable.length)
		{
			if(!Std.is(typeTable[i], SubstituteType))
				continue;
			
			cast(typeTable[i], SubstituteType).mapTypes(subTypeMap);
		}
	}

	public function reconfigureComposition(type:ComposedType):Void
	{
		if(subTypeMap.exists(type.getName()))
		{
			var subType:ComposedType = cast subTypeMap.get(type.getName());
			var fieldMap = new Map<String, MbsField>();
			for(f in subType.getFields())
			{
				fieldMap.set(f.getName(), f);
			}
			
			for(f in type.getFields())
			{
				f.address = fieldMap.get(f.getName()).address;
			}
		}
	}
	
	public function getRoot():Dynamic
	{
		return header.getRoot();
	}

	public function traceInfo()
	{
		trace("TYPES:");
		trace(typeTable);
		trace("");
		
		trace("STRINGS:");
		trace(stringTable);
		trace("");

		var root = header.getRoot();
		if(Std.is(root, MbsObject))
		{
			var mo:MbsObject = cast root;
			root = readObject(mo.getMbsType(), mo.getAddress());
		}
		
		trace("ROOT:");
		trace(root);
	}

	private var genObj:MbsGenericObject;

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
			case "dynamic": readDynamic(r.readInt(f));
			default: readObject(f.type, r.readInt(f));
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
	
	public function readInt(pos:Int):Int
	{
		return (data.get(pos + 0) << 24) | (data.get(pos + 1) << 16) | (data.get(pos + 2) << 8) | data.get(pos + 3);
	}

	public function readBool(pos:Int):Bool
	{
		return data.get(pos) != 0;
	}

	public function readFloat(pos:Int):Float
	{
		return FPHelper.i32ToFloat(readInt(pos));
	}

	public function readString(pos:Int):String 
	{
		return stringTable[readInt(pos)];
	}
	
	public function readTypecode(pos:Int):MbsType
	{
		return typeTable[readInt(pos)];
	}

	public function getTypeTable():Vector<MbsType> 
	{
		return typeTable;
	}

	public function writeInt(address:Int, value:Int):Void
	{
		throw "Can't write on an MBS reader";
	}

	public function writeBool(address:Int, value:Bool):Void
	{
		throw "Can't write on an MBS reader";
	}

	public function writeFloat(address:Int, value:Float):Void
	{
		throw "Can't write on an MBS reader";
	}

	public function writeString(address:Int, value:String):Void
	{
		throw "Can't write on an MBS reader";
	}

	public function isReader():Bool
	{
		return true;
	}

	public function isWriter():Bool
	{
		return false;
	}

	public function allocate(size:Int):Int
	{
		throw "Can't allocate on an MBS reader";
	}

	public function writeTypecode(address:Int, type:MbsType):Void
	{
		throw "Can't write on an MBS reader";
	}
}