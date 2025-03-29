/// Change active namespace on this server
Class Production.Message.ChangeNamespaceIn Extends (Ens.Request, %JSON.Adaptor)
{

Property Name As %String;

Storage Default
{
<Data name="ChangeNamespaceInDefaultData">
<Subscript>"ChangeNamespaceIn"</Subscript>
<Value name="1">
<Value>Name</Value>
</Value>
</Data>
<DefaultData>ChangeNamespaceInDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
