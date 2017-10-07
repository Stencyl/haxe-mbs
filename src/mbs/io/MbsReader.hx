package mbs.io;

import haxe.io.Bytes;
import haxe.io.FPHelper;
import haxe.ds.Vector;

import mbs.core.header.MbsFieldInfo;
import mbs.core.header.MbsHeader;
import mbs.core.header.MbsTypeInfo;
import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsTypedefSet;
import mbs.core.MbsTypes.*;
import mbs.core.reflect.SubstituteField;
import mbs.core.reflect.SubstituteType;

class MbsReader implements MbsIO
{
	private var data:Bytes;

	private var stringTable:Vector<String>;
	private var typeTable:Vector<MbsType>;
	private var rootAddress:Int;

	private var subTypeMap:Map<String, MbsType>;

	private var readStoredTypeInformation:Bool;
	private var typedefSet:MbsTypedefSet;

	private var header:MbsHeader;

	public function new(data:Bytes, typedefSet:MbsTypedefSet, readStoredTypeInformation:Bool) 
	{
		this.data = data;
		this.typedefSet = typedefSet;
		this.readStoredTypeInformation = readStoredTypeInformation;
		
		readData();
	}

	public function readData():Void 
	{
		header = new MbsHeader(this);
		header.setAddress(0);
		
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

		if(readStoredTypeInformation)
		{
			var typeInfo = new MbsTypeInfo(this);

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
		else
		{
			typeTable = new Vector<MbsType>(typedefSet.getTypes().length);
			for(type in typedefSet.getTypes())
			{
				typeTable[typedefSet.getTypecode(type)] = type;
			}
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