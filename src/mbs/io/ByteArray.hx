package mbs.io;

import haxe.io.Bytes;
import sys.io.File;
import sys.io.FileOutput;

class ByteArray
{
	private var bytes:Array<Bytes>;

	private static var BUFFER_SIZE(default,never):Int = 1024 * 8;

	// allocation tracking
	private var alloc_nextIndex:Int;

	// fast access
	private var currentBuffer:Bytes;
	private var currentBufferMin:Int;
	private var currentBufferMax:Int;

	public function new()
	{
		bytes = new Array<Bytes>();
		alloc_nextIndex = 0;
	}

	private function ensureCapacity(size:Int):Void
	{
		var bufferIndex:Int = Std.int(size / BUFFER_SIZE);
		while(bytes.size() <= bufferIndex)
		{
			bytes.add(Bytes.alloc(BUFFER_SIZE));
		}
	}

	private function setBuffer(i:Int):Void
	{
		currentBuffer = bytes.get(i);
		currentBufferMin = i * BUFFER_SIZE;
		currentBufferMax = (i + 1) * BUFFER_SIZE - 1;
	}

	public function clear():Void
	{
		var bufferAllocatedLength:Int = alloc_nextIndex;
		for(i in 0...bytes.length)
		{
			if (bufferAllocatedLength >= BUFFER_SIZE)
				bytes.get(i).fill(0, BUFFER_SIZE, 0);
			else if (bufferAllocatedLength > 0)
				bytes.get(i).fill(0, bufferAllocatedLength, 0);
			else
				break;
			
			bufferAllocatedLength -= BUFFER_SIZE;
		}
		alloc_nextIndex = 0;
	}

	public function allocate(size:Int):Int
	{
		var newBytes:Int = alloc_nextIndex;
		alloc_nextIndex += size;
		ensureCapacity(newBytes + size);
		return newBytes;
	}

	public function writeInt(pos:Int, i:Int):Void
	{
		write(pos + 0, (0xFF & (i >> 24)));
		write(pos + 1, (0xFF & (i >> 16)));
		write(pos + 2, (0xFF & (i >> 8)));
		write(pos + 3, (0xFF & (i)));
	}

	public function writeFloat(pos:Int, f:Float):Void
	{
		writeInt(pos, FPHelper.floatToI32(f));
	}

	public function writeBool(pos:Int, b:Bool):Void
	{
		write(pos, b ? 1 : 0);
	}

	public function writeBytes(i:Int, b:Array<Int>):Void
	{
		for(i2 in 0...b.length)
		{
			write(i + i2, 0xFF & b[i2]);
		}
	}

	private function write(pos:Int, b:Int):Void
	{
		if(pos < currentBufferMin || pos > currentBufferMax)
		{
			setBuffer(pos / BUFFER_SIZE);
		}

		currentBuffer.set(pos - currentBufferMin, b);
	}

	#if cpp
	public function writeToFile(loc:File):Void
	{
		var fo:FileOutput = File.write(loc, true);

		fo.writeBytes( s : haxe.io.Bytes, p : Int, l : Int ) : Int {
			return try NativeFile.file_write(__f,s.getData(),p,l) catch( e : Dynamic ) throw haxe.io.Error.Custom(e);
		}

		try
		{
			var bufferAllocatedLength:Int = alloc_nextIndex;
			for(i in 0...bytes.size())
			{
				if (bufferAllocatedLength >= BUFFER_SIZE)
					fo.writeBytes(bytes.get(i), 0, BUFFER_SIZE);
				else if (bufferAllocatedLength > 0)
					fos.write(bytes.get(i), 0, bufferAllocatedLength);
				else
					break;
				
				bufferAllocatedLength -= BUFFER_SIZE;
			}
		}
		catch (e:Dynamic)
		{
			trace(e);
		}

		fo.close();
	}
	#end
}