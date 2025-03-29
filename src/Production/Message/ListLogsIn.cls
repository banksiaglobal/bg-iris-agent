/// List logs available on this server
Class Production.Message.ListLogsIn Extends (Ens.Request, %JSON.Adaptor)
{

/// You can indicate a part of log's text to perform search
Property LogSearch As %String;

Storage Default
{
<Data name="ListLogsInDefaultData">
<Subscript>"ListLogsIn"</Subscript>
<Value name="1">
<Value>LogSearch</Value>
</Value>
</Data>
<DefaultData>ListLogsInDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
