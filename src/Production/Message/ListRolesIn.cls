/// List all roles available on this server
Class Production.Message.ListRolesIn Extends (Ens.Request, %JSON.Adaptor)
{

/// You can indicate a part of roles's description to perform search
Property DescriptionSearch As %String;

Storage Default
{
<Data name="ListRolesnInDefaultData">
<Subscript>"ListRolesnIn"</Subscript>
<Value name="1">
<Value>DescriptionSearch</Value>
</Value>
</Data>
<DefaultData>ListRolesnInDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
