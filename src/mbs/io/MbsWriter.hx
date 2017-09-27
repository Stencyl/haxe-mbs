package mbs.io;

import sys.io.File;

import mbs.core.ComposedType;
import mbs.core.MbsField;
import mbs.core.MbsType;
import mbs.core.MbsHeader.*;
import mbs.core.MbsTypes.*;
import mbs.io.ByteArray;

class MbsWriter implements MbsIO
{
	private var bytes:ByteArray;

	private var stringTable:Map<String, TableRecord>;
	private var stringTableIndex:Int = -1;

	private var typeTable:Map<MbsType, TableRecord>;
	private var typeTableIndex:Int = -1;
	
	private var headerWriter:MbsGenericObject;

	public function new() 
	{
		bytes = new ByteArray();
		stringTable = new Map<String,TableRecord>();
		typeTable = new Map<Type,TableRecord>();
		
		headerWriter = new MbsGenericObject(this, MBS_HEADER);

		// Allocate a HEADER_INFO before anything else so it has a constant placement at the start of the file.
		allocate(MBS_HEADER.getSize());

		//Ensure the empty string is placed at index 0 in the string table.
		getStringIndex("");

		registerType(BOOLEAN);
		registerType(INTEGER);
		registerType(FLOAT);
		registerType(STRING);
		registerType(LIST);
		registerType(DYNAMIC);

		registerType(MBS_HEADER);
		registerType(TYPE_INFO);
		registerType(FIELD_INFO);
	}

	public function allocate(size:Int):Int 
	{
		return bytes.allocate(size);
	}

	public function setRoot(type:MbsType, object:MbsObject):Void
	{
		writeInt(ROOT.address, typeTable.get(type).index);
		writeInt(ROOT.address + INTEGER.getSize(), object.getAddress());
	}

	public function prepareForOutput():Void 
	{
		//enter data manually in a format similar to lists, but without typecodes.
		//we won't know the typecodes anyway when reading back in.

		var intSize = INTEGER.getSize();
		
		var listAddress = bytes.allocate(intSize + intSize * stringTable.size());
		bytes.writeInt(listAddress, stringTable.size());
		
		for(record in stringTable)
		{
			bytes.writeInt(listAddress + intSize + (record.index * intSize), record.address);
		}
		
		headerWriter.writeInt(STRING_TABLE, listAddress);
		
		//
		
		listAddress = bytes.allocate(intSize + intSize * typeTable.size());
		bytes.writeInt(listAddress, typeTable.size());
		
		for(record in typeTable)
		{
			bytes.writeInt(listAddress + intSize + (record.index * intSize), record.address);
		}
		
		headerWriter.writeInt(TYPE_TABLE, listAddress);
	}

	public function writeToFile(loc:File):Void 
	{
		bytes.writeToFile(loc);
	}

	public function writeBool(address:Int, value:Bool):Void 
	{
		bytes.writeBool(address, value);
	}

	public function writeFloat(address:Int, value:Float):Void 
	{
		bytes.writeFloat(address, value);
	}

	public function writeInt(address:Int, value:Int):Void 
	{
		bytes.writeInt(address, value);
	}

	public function writeString(address:Int, value:String):Void 
	{
		bytes.writeInt(address, getStringTableIndex(value));
	}

	// Type Table

	private var typeWriter:MbsGenericObject = new MbsGenericObject(this, TYPE_INFO);
	
	public function registerType(type:MbsType):Void
	{
		if(!typeTable.exists(type))
		{
			typeWriter.allocateNew();
			typeWriter.writeString(TYPE_NAME, type.getName());
			typeWriter.writeInt(TYPE_SIZE, type.getSize());
			
			if(Std.is(type, ComposedType))
			{
				var cType:ComposedType = cast type;
				
				if(cType.getParent() != null)
				{
					typeWriter.writeString(TYPE_PARENT, cType.getParent().getName());
				}
				
				if(cType.getFields().length != 0)
				{
					var fields = bytes.allocate(INTEGER.getSize() + FIELD_INFO.getSize() * cType.getFields().size());
					typeWriter.writeInt(TYPE_FIELDS, fields);
					writeInt(fields, cType.getFields().size());
					fields += INTEGER.getSize();
					
					var fieldWriter = new MbsGenericObject(this, FIELD_INFO);
					
					for(field in cType.getFields())
					{
						fieldWriter.setAddress(fields);
						fields += FIELD_INFO.getSize();
						
						fieldWriter.writeString(FIELD_NAME, field.getName());
						fieldWriter.writeString(FIELD_TYPE, field.getType().getName());
						fieldWriter.writeInt(FIELD_ADDRESS, field.getAddress());
					}
				}
			}
			
			var r = new TableRecord(typeWriter.getAddress(), ++typeTableIndex);
			typeTable.put(type, r);
		}
	}

	public function writeTypecode(address:Int, type:MbsType):Void
	{
		var typecode = typeTable.get(type).index;
		bytes.writeInt(address, typecode);
	}

	// String Table

	public function getStringIndex(value:String):Int
	{
		if (!stringTable.exists(value))
		{
			var asBytes:Vector<Int> = value.getBytes(MbsWriter.UTF_8);

			var newString:Int = bytes.allocate(asBytes.length + 4);
			bytes.writeInt(newString, asBytes.length);
			bytes.writeBytes(newString + 4, asBytes);

			var r = new TableRecord(newString, ++stringTableIndex);
			stringTable.put(value, r);
		}

		return stringTable.get(value).index;
	}

	public function readBool(address:Int):Bool
	{
		throw "Can't read on an MBS writer";
	}

	public function readFloat(address:Int):Float
	{
		throw "Can't read on an MBS writer";
	}

	public function readInt(address:Int):Int
	{
		throw "Can't read on an MBS writer";
	}

	public function readString(address:Int):String
	{
		throw "Can't read on an MBS writer";
	}

	public function isReader():Bool
	{
		return false;
	}

	public function isWriter():Bool
	{
		return true;
	}

	public function readTypecode(address:Int):MbsType
	{
		throw "Can't read on an MBS writer";
	}
}

class TableRecord
{
	public var address:Int;
	public var index:Int;

	public function new(address:Int, index:Int) 
	{
		this.address = address;
		this.index = index;
	}
}