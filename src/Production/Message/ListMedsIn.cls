/// Search of medicine on the external API
Class Production.Message.ListMedsIn Extends (Ens.Request, %JSON.Adaptor)
{

/// You can indicate a part of medicine's description to perform search
Property Name As %String;

Property Limit As %String;

Storage Default
{
<Data name="ListMedsInDefaultData">
<Subscript>"ListMedsIn"</Subscript>
<Value name="1">
<Value>Name</Value>
</Value>
<Value name="2">
<Value>Limit</Value>
</Value>
</Data>
<DefaultData>ListMedsInDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
