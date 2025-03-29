/// List all services available on this server
Class Production.Message.ListServicesIn Extends (Ens.Request, %JSON.Adaptor)
{

/// You can indicate a part of services's description to perform search
Property DescriptionSearch As %String;

Storage Default
{
<Data name="ListServicesInInDefaultData">
<Subscript>"ListServicesIn"</Subscript>
<Value name="1">
<Value>DescriptionSearch</Value>
</Value>
</Data>
<DefaultData>ListServicesInDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
