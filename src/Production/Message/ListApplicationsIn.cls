/// List all applications available on this server
Class Production.Message.ListApplicationsIn Extends (Ens.Request, %JSON.Adaptor)
{

/// You can indicate a part of application's name to perform search
Property NameSearch As %String;

Storage Default
{
<Data name="ListApplicationsInDefaultData">
<Subscript>"ListApplicationsIn"</Subscript>
<Value name="1">
<Value>NameSearch</Value>
</Value>
</Data>
<DefaultData>ListApplicationsInDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
