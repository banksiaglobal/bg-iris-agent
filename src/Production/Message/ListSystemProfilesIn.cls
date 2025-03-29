/// List all system profiles available on this server
Class Production.Message.ListSystemProfilesIn Extends (Ens.Request, %JSON.Adaptor)
{

/// You can indicate a part of username to perform search
Property UsernameSearch As %String;

Storage Default
{
<Data name="ListSystemProfilesInDefaultData">
<Subscript>"ListSystemProfilesIn"</Subscript>
<Value name="1">
<Value>UsernameSearch</Value>
</Value>
</Data>
<DefaultData>ListSystemProfilesInDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
