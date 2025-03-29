/// List all users available on this server
Class Production.Message.ListUsersIn Extends (Ens.Request, %JSON.Adaptor)
{

/// You can indicate a part of user's name to perform search
Property NameSearch As %String;

Storage Default
{
<Data name="ListUsersInDefaultData">
<Subscript>"ListUsersIn"</Subscript>
<Value name="1">
<Value>NameSearch</Value>
</Value>
</Data>
<DefaultData>ListUsersInDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
