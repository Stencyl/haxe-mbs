package mbs.core;

import mbs.core.MbsTypes.*;

class MbsHeader
{
	//Types
	public static var MBS_HEADER = new ComposedType("mbsHeader");
	public static var TYPE_INFO = new ComposedType("mbsTypeInfo");
	public static var FIELD_INFO = new ComposedType("mbsFieldInfo");

	//Fields
	public static var TYPE_TABLE = MBS_HEADER.createField("typeTable", INTEGER /*Points to a custom TYPE_INFO list*/);
	public static var STRING_TABLE = MBS_HEADER.createField("stringTable", INTEGER  /*Points to a custom STRING list*/);
	public static var ROOT = MBS_HEADER.createField("root", DYNAMIC);

	public static var TYPE_NAME = TYPE_INFO.createField("typeName", STRING);
	public static var TYPE_PARENT = TYPE_INFO.createField("typeParent", STRING);
	public static var TYPE_FIELDS = TYPE_INFO.createField("typeFields", INTEGER /*Points to a custom FIELD_INFO list*/);
	public static var TYPE_SIZE = TYPE_INFO.createField("typeSize", INTEGER);

	public static var FIELD_NAME = FIELD_INFO.createField("fieldName", STRING);
	public static var FIELD_TYPE = FIELD_INFO.createField("fieldType", STRING);
	public static var FIELD_ADDRESS = FIELD_INFO.createField("fieldAddress", INTEGER);
}

