/// List errors available on this server
Class Production.Message.ListErrorsIn Extends (Ens.Request, %JSON.Adaptor)
{

/// You can indicate a part of error's text to perform search
Property ErrorSearch As %String;

Storage Default
{
<Data name="ListErrorsInDefaultData">
<Subscript>"ListErrorsIn"</Subscript>
<Value name="1">
<Value>ErrorSearch</Value>
</Value>
</Data>
<DefaultData>ListErrorsInDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
