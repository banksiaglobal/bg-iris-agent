/// List messages available on this server
Class Production.Message.ListMessagesIn Extends (Ens.Request, %JSON.Adaptor)
{

/// You can indicate a part of message's text to perform search
Property MessageSearch As %String;

Storage Default
{
<Data name="ListMessagesInDefaultData">
<Subscript>"ListMessagesIn"</Subscript>
<Value name="1">
<Value>MessageSearch</Value>
</Value>
</Data>
<DefaultData>ListMessagesInDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
