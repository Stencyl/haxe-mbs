package mbs.io.read;

import mbs.core.MbsType;

class MbsDynamicReader extends MbsReaderHelper
{
	private var typecodeLength:Int;
	
	public function new(reader:MbsReader)
	{
		super(reader);
		typecodeLength = reader.getTypecodeLength();
	}
	
	public function getType():MbsType
	{
		return reader.readTypecode(address);
	}
	
	public function readBool():Bool
	{
		return reader.readBool(address + typecodeLength);
	}
	
	public function readFloat():Float
	{
		return reader.readFloat(address + typecodeLength);
	}
	
	public function readInt():Int
	{
		return reader.readInt(address + typecodeLength);
	}
	
	public function readString():String
	{
		return reader.readString(address + typecodeLength);
	}
	
	private var objReader:MbsObjectReader = null;
	
	public function readObject():MbsObjectReader
	{
		if(objReader == null)
			objReader = new MbsObjectReader(reader);
		objReader.setAddress(reader.readInt(address + typecodeLength));
		
		return objReader;
	}
	
	public function readList():MbsListReader
	{
		var r = new MbsListReader(reader);
		r.setAddress(reader.readInt(address + typecodeLength));
		
		return r;
	}
	
	public function readMap():MbsMapReader
	{
		var r = new MbsMapReader(reader);
		r.setAddress(reader.readInt(address + typecodeLength));
		
		return r;
	}
}
