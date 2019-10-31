package mbs.io;

import mbs.core.MbsObject;
import mbs.core.MbsType;
import mbs.core.MbsTypes.*;
import mbs.io.MbsListBase.MbsBoolList;
import mbs.io.MbsListBase.MbsDynamicList;
import mbs.io.MbsListBase.MbsFloatList;
import mbs.io.MbsListBase.MbsIntList;
import mbs.io.MbsListBase.MbsStringList;

typedef DynamicPool = Map<MbsType, MbsObject>;

class MbsDynamicHelper
{
	public static function writeDynamic(data:MbsIO, address:Int, obj:Dynamic):Void
	{
		if(obj == null)
		{
			data.writeTypecode(address, NULL);
		}
		if(Std.is(obj, Bool))
		{
			data.writeTypecode(address, BOOLEAN);
			data.writeBool(address + INTEGER.getSize(), cast obj);
		}
		else if(Std.is(obj, Float))
		{
			data.writeTypecode(address, FLOAT);
			data.writeFloat(address + INTEGER.getSize(), cast obj);
		}
		else if(Std.is(obj, Int))
		{
			data.writeTypecode(address, INTEGER);
			data.writeInt(address + INTEGER.getSize(), cast obj);
		}
		else if(Std.is(obj, String))
		{
			data.writeTypecode(address, STRING);
			data.writeString(address + INTEGER.getSize(), cast obj);
		}
		else
		{
			var mo:MbsObject = cast obj;
			data.writeTypecode(address, mo.getMbsType());
			data.writeInt(address + INTEGER.getSize(), mo.getAddress());
		}
	}

	public static function readDynamic(data:MbsIO, address:Int):Dynamic
	{
		var type = data.readTypecode(address);
		if(type == NULL)
			return null;
		else if(type == BOOLEAN)
			return data.readBool(address + INTEGER.getSize());
		else if(type == FLOAT)
			return data.readFloat(address + INTEGER.getSize());
		else if(type == INTEGER)
			return data.readInt(address + INTEGER.getSize());
		else if(type == STRING)
			return data.readString(address + INTEGER.getSize());
		else if(type == LIST)
		{
			address = data.readInt(address + INTEGER.getSize());
			if(address != 0)
			{
				type = data.readTypecode(address + INTEGER.getSize());
				var list:MbsListBase = null;
				if(type == BOOLEAN)
					list = new MbsBoolList(data);
				else if(type == FLOAT)
					list = new MbsFloatList(data);
				else if(type == INTEGER)
					list = new MbsIntList(data);
				else if(type == STRING)
					list = new MbsStringList(data);
				else if(type == DYNAMIC)
					list = new MbsDynamicList(data);
				else
					list = new MbsList(data, type, type.createInstance(data));
				list.setAddress(address);
				return list;
			}
			return null;
		}
		else
		{
			var obj:MbsObject = type.createInstance(data);
			obj.setAddress(data.readInt(address + INTEGER.getSize()));
			return obj;
		}
	}

	public static function createObjectPool(data:MbsIO):DynamicPool
	{
		return new Map<MbsType, MbsObject>();
	}

	public static function readDynamicUsingPool(data:MbsIO, address:Int, pool:DynamicPool):Dynamic
	{
		var type = data.readTypecode(address);
		if(type == NULL)
			return null;
		else if(type == BOOLEAN)
			return data.readBool(address + INTEGER.getSize());
		else if(type == FLOAT)
			return data.readFloat(address + INTEGER.getSize());
		else if(type == INTEGER)
			return data.readInt(address + INTEGER.getSize());
		else if(type == STRING)
			return data.readString(address + INTEGER.getSize());
		else if(type == LIST)
		{
			address = data.readInt(address + INTEGER.getSize());
			if(address != 0)
			{
				type = data.readTypecode(address + INTEGER.getSize());
				var list:MbsListBase = null;
				if(type == BOOLEAN)
					list = new MbsBoolList(data);
				else if(type == FLOAT)
					list = new MbsFloatList(data);
				else if(type == INTEGER)
					list = new MbsIntList(data);
				else if(type == STRING)
					list = new MbsStringList(data);
				else if(type == DYNAMIC)
					list = new MbsDynamicList(data);
				else
					list = new MbsList(data, type, type.createInstance(data));
				list.setAddress(address);
				return list;
			}
			return null;
		}
		else
		{
			var obj:MbsObject = pool.get(type);
			if(obj == null)
			{
				obj = type.createInstance(data);
				pool.set(type, obj);
			}

			obj.setAddress(data.readInt(address + INTEGER.getSize()));
			return obj;
		}
	}
}
