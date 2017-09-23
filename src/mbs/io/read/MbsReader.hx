package mbs.io.read;

import haxe.io.Bytes;
import haxe.io.FPHelper;
import haxe.ds.Vector;
#if sys
import sys.io.File;
#end

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsHeader.*;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.core.sub.SubstituteField;
import mbs.core.sub.SubstituteObject;
import mbs.core.sub.SubstituteType;

class MbsReader
{
	private var data:Bytes;

	private var stringTable:Vector<String>;
	private var typeTable:Vector<MbsType>;
	private var rootAddress:Int;
	private var typecodeLength:Int;

	private var subTypeMap:Map<String, MbsType>;

	private var header:MbsObjectReader;
	private var headerRoot:MbsDynamicReader;

	#if sys
	public static function main():Void
	{
		new MbsReader(File.getBytes("D:/stencylworks/games/blank mbs copy/resources/data.xml")).traceInfo();
	}
	#end

	public function new(data:Bytes) 
	{
		this.data = data;
		readData();
	}

	public function readData():Void 
	{
		header = new MbsObjectReader(this);
		header.setAddress(0);
		
		var typeInfo = new MbsObjectReader(this);
		var intSize = INTEGER.getSize();
		
		var readAddress = header.readInt(STRING_TABLE);
		stringTable = new Vector<String>(readInt(readAddress));
		readAddress += intSize;
		for(i in 0...stringTable.length) 
		{
			var pos = readInt(readAddress);
			var length = readInt(pos);
			stringTable[i] = data.getString(pos + 4, length);
			readAddress += intSize;
		}

		readAddress = header.readInt(TYPE_TABLE);
		typeTable = new Vector<MbsType>(readInt(readAddress));
		readAddress += intSize;
		
		typecodeLength = 0;
		var numTypes = typeTable.length;
		while(numTypes > 0)
		{
			++typecodeLength;
			numTypes >>= 8;
		}
		
		subTypeMap = new Map<String, MbsType>();
		var primTypeMap = [for(type in [BOOLEAN, INTEGER, FLOAT, STRING, DYNAMIC, LIST, MAP]) type.getName() => type];
		
		for(i in 0...typeTable.length) 
		{
			typeInfo.setAddress(readInt(readAddress));
			readAddress += intSize;

			var name = typeInfo.readString(TYPE_NAME);
			var parentType = typeInfo.readString(TYPE_PARENT);
			var size = typeInfo.readInt(TYPE_SIZE);
			var fields:Vector<MbsField> = null;

			var fieldListAddress = typeInfo.readInt(TYPE_FIELDS);
			if(fieldListAddress != 0)
			{
				var fieldListLength = readInt(fieldListAddress);
				fieldListAddress += intSize;
				
				fields = new Vector<MbsField>(fieldListLength);
				var fieldInfo = new MbsObjectReader(this);
				
				for(j in 0...fieldListLength)
				{
					fieldInfo.setAddress(fieldListAddress);
					fieldListAddress += FIELD_INFO.getSize();
					
					var fieldName = fieldInfo.readString(FIELD_NAME);
					var fieldType = fieldInfo.readString(FIELD_TYPE);
					var fieldAddress = fieldInfo.readInt(FIELD_ADDRESS);
					
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
		
		headerRoot = header.readDynamic(ROOT);
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

	public function getRoot():MbsDynamicReader
	{
		return headerRoot;
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
		trace(readDynamic(header.readDynamic(ROOT)));
	}

	private function readDynamic(r:MbsDynamicReader):Dynamic
	{
		return switch(r.getType().getName())
		{
			case "boolean": r.readBool();
			case "integer": r.readInt();
			case "float": r.readFloat();
			case "string": r.readString();
			case "list": readList(r.readList());
			case "map": readMap(r.readMap());
			case "dynamic": "Dynamic?";
			default: readObject(r.getType(), r.readObject());
		};
	}

	private function readObject(type:MbsType, r:MbsObjectReader):SubstituteObject
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
		
		for(f in fields)
		{
			obj.set(f.getName(), readField(r, f));
		}
		
		return obj;
	}

	private function readField(r:MbsObjectReader, f:MbsField):Dynamic
	{
		return switch(f.type.getName())
		{
			case "boolean": r.readBool(f);
			case "integer": r.readInt(f);
			case "float": r.readFloat(f);
			case "string": r.readString(f);
			case "list": readList(r.readList(f));
			case "map": readMap(r.readMap(f));
			case "dynamic": readDynamic(r.readDynamic(f));
			default: readObject(f.type, r.readObject(f));
		}
	}

	private function readList(r:MbsListReader):Vector<Dynamic>
	{
		var list = new Vector<Dynamic>(r.length());
		for(i in 0...r.length())
		{
			switch(r.getType().getName())
			{
				case "boolean": list[i] = r.readBool();
				case "integer": list[i] = r.readInt();
				case "float": list[i] = r.readFloat();
				case "string": list[i] = r.readString();
				case "dynamic": list[i] = readDynamic(r.readDynamic());
				default: list[i] = readObject(r.getType(), r.readObject());
			}
		}
		return list;
	}
	
	private function readMap(r:MbsMapReader):Map<String, Dynamic>
	{
		var map = new Map<String, Dynamic>();
		for(i in 0...r.length())
		{
			switch(r.getValueType().getName())
			{
				case "boolean":
					map.set(r.readStringKey(), r.readBool());
				case "integer":
					map.set(r.readStringKey(), r.readInt());
				case "float":
					map.set(r.readStringKey(), r.readFloat());
				case "string":
					map.set(r.readStringKey(), r.readString());
				case "dynamic":
					map.set(r.readStringKey(), readDynamic(r.readDynamic()));
				case "object":
					map.set(r.readStringKey(), "Object??");
				default:
					map.set(r.readStringKey(), readObject(r.getValueType(), r.readObject()));
			}
		}
		return map;
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
		return typeTable[readVarInt(pos, typecodeLength)];
	}

	private function readVarInt(pos:Int, bytesToUse:Int):Int
	{
		return switch (bytesToUse)
		{
			case 1 : data.get(pos + 0);
			case 2 : (data.get(pos + 0) << 8) | data.get(pos + 1);
			case 3 : (data.get(pos + 0) << 16) | (data.get(pos + 1) << 8) | data.get(pos + 2);
			case 4 : (data.get(pos + 0) << 24) | (data.get(pos + 1) << 16) | (data.get(pos + 2) << 8) | data.get(pos + 3);
			default: 0;
		}
	}

	public function getTypecodeLength():Int 
	{
		return typecodeLength;
	}

	public function getTypeTable():Vector<MbsType> 
	{
		return typeTable;
	}
}