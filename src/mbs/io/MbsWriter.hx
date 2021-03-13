package mbs.io;

import mbs.core.ComposedType;
import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypedefSet;
import mbs.core.header.*;
import mbs.core.MbsTypes.*;
import mbs.io.ByteArray;

class MbsWriter implements MbsIO
{
	private var bytes:ByteArray;

	private var stringTable:Map<String, TableRecord>;
	private var stringTableIndex:Int = -1;

	private var typeTable:Map<MbsType, TableRecord>;
	private var typeTableIndex:Int = -1;

	private var storeTypeInformation:Bool;
	private var typedefSet:MbsTypedefSet;
	
	private var header:MbsHeader;

	public function new(typedefSet:MbsTypedefSet, storeTypeInformation:Bool) 
	{
		bytes = new ByteArray();
		stringTable = new Map<String,TableRecord>();
		typeTable = new Map<MbsType,TableRecord>();
		
		header = new MbsHeader(this);
 		typeWriter = new MbsTypeInfo(this);

		this.typedefSet = typedefSet;
		this.storeTypeInformation = storeTypeInformation;

		// Allocate a HEADER_INFO before anything else so it has a constant placement at the start of the file.
		header.allocateNew();

		//Ensure the empty string is placed at index 0 in the string table.
		getStringIndex("");

		if(storeTypeInformation)
		{
			for(type in typedefSet.getTypes())
			{
				registerType(type);
			}
		}

		header.setVersion(MbsInternalVersion.VERSION);
		header.setTypeTableHash(typedefSet.getHash());
	}

	public function allocate(size:Int):Int 
	{
		return bytes.allocate(size);
	}

	public function setRoot(object:MbsObject):Void
	{
		header.setRoot(object);
	}

	public function prepareForOutput():Void 
	{
		//enter data manually in a format similar to lists, but without typecodes.
		//we won't know the typecodes anyway when reading back in.

		var intSize = INTEGER.getSize();
		
		var listAddress:Int;
		
		listAddress = bytes.allocate(intSize + intSize * (stringTableIndex + 1));
		bytes.writeInt(listAddress, (stringTableIndex + 1));
		
		for(record in stringTable)
		{
			bytes.writeInt(listAddress + intSize + (record.index * intSize), record.address);
		}
		
		header.setStringTablePointer(listAddress);
		
		//
		
		if(storeTypeInformation)
		{
			listAddress = bytes.allocate(intSize + intSize * (typeTableIndex + 1));
			bytes.writeInt(listAddress, (typeTableIndex + 1));
			
			for(record in typeTable)
			{
				bytes.writeInt(listAddress + intSize + (record.index * intSize), record.address);
			}
			
			header.setTypeTablePointer(listAddress);
		}
	}

	#if sys
	public function writeToFile(loc:String):Void 
	{
		bytes.writeToFile(loc);
	}
	#end

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
		bytes.writeInt(address, getStringIndex(value));
	}

	// Type Table

	private var typeWriter:MbsTypeInfo;
	
	public function registerType(type:MbsType):Void
	{
		if(!typeTable.exists(type))
		{
			typeWriter.allocateNew();
			typeWriter.setName(type.getName());
			typeWriter.setSize(type.getSize());
			
			if(Std.isOfType(type, ComposedType))
			{
				var cType:ComposedType = cast type;
				
				if(cType.getParent() != null)
				{
					typeWriter.setParent(cType.getParent().getName());
				}
				
				if(cType.getFields().length != 0)
				{
					var fieldWriter = new MbsFieldInfo(this);

					var fields = bytes.allocate(INTEGER.getSize() + fieldWriter.getMbsType().getSize() * cType.getFields().length);
					typeWriter.setFieldsPointer(fields);
					writeInt(fields, cType.getFields().length);
					fields += INTEGER.getSize();
					
					for(field in cType.getFields())
					{
						fieldWriter.setAddress(fields);
						fields += fieldWriter.getMbsType().getSize();
						
						fieldWriter.setName(field.getName());
						fieldWriter.setType(field.getType().getName());
						fieldWriter.setFieldAddress(field.getAddress());
					}
				}
			}
			
			var r = new TableRecord(typeWriter.getAddress(), ++typeTableIndex);
			typeTable.set(type, r);
		}
	}

	public function writeTypecode(address:Int, type:MbsType):Void
	{
		var typecode = storeTypeInformation ? typeTable.get(type).index : typedefSet.getTypecode(type);
		bytes.writeInt(address, typecode);
	}

	// String Table

	public function getStringIndex(value:String):Int
	{
		if (!stringTable.exists(value))
		{
			var asBytes = haxe.io.Bytes.ofString(value);

			var newString:Int = bytes.allocate(asBytes.length + 4);
			bytes.writeInt(newString, asBytes.length);
			bytes.writeBytes(newString + 4, asBytes);

			var r = new TableRecord(newString, ++stringTableIndex);
			stringTable.set(value, r);
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