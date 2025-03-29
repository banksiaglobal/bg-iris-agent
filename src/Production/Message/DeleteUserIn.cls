/// Delete user on this server
Class Production.Message.DeleteUserIn Extends (Ens.Request, %JSON.Adaptor)
{

Property Name As %String;

Storage Default
{
<Data name="DeleteUserInDefaultData">
<Subscript>"DeleteUserIn"</Subscript>
<Value name="1">
<Value>Name</Value>
</Value>
</Data>
<DefaultData>DeleteUserInDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
