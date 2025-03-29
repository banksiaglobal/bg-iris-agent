/// Create new user on this server
Class Production.Message.NewUserIn Extends (Ens.Request, %JSON.Adaptor)
{

Property Name As %String;

Property Password As %String;

Storage Default
{
<Data name="NewUserInDefaultData">
<Subscript>"NewUserIn"</Subscript>
<Value name="1">
<Value>Name</Value>
</Value>
<Value name="2">
<Value>Password</Value>
</Value>
</Data>
<DefaultData>NewUserInDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
