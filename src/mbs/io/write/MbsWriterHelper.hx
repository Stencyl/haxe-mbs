package mbs.io.write;

public class MbsWriterHelper
{
    @:allow(mbs.io.write)
	private var writer:MbsWriter;
    @:allow(mbs.io.write)
	private var address:Int;
	
	public function new(writer:MbsWriter)
	{
		this.writer = writer;
	}
	
	public MbsWriter getWriter()
	{
		return writer;
	}
	
	@:allow(mbs.io.write)
	private int getAddress()
	{
		return address;
	}
}
