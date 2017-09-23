package mbs.io.read;

class MbsReaderHelper
{
	@:allow(mbs.io.read)
	private var reader:MbsReader;
	@:allow(mbs.io.read)
	private var address:Int;
	
	public function new(reader:MbsReader)
	{
		this.reader = reader;
	}
	
	public function getReader():MbsReader
	{
		return reader;
	}
	
	@:allow(mbs.io.read)
    private function getAddress():Int
	{
		return address;
	}

	@:allow(mbs.io.read)
    private function setAddress(address:Int):Void
	{
		this.address = address;
	}
}