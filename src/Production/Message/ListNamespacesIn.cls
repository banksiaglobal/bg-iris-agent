/// List all namespaces available on this server
Class Production.Message.ListNamespacesIn Extends (Ens.Request, %JSON.Adaptor)
{

/// You can indicate a part of namespace's name to perform search
Property NameSearch As %String;

Storage Default
{
<Data name="ListNamespacesInDefaultData">
<Subscript>"ListNamespacesIn"</Subscript>
<Value name="1">
<Value>NameSearch</Value>
</Value>
</Data>
<DefaultData>ListNamespacesInDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
