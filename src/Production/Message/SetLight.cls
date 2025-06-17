/// Set light state
Class Production.Message.SetLight Extends (Ens.Request, %JSON.Adaptor)
{

/// State of the light: "On" to turn on the light, "Off" to turn off the light, empty to remain in the current state
Property State As %String;

/// Color of the light: "Red" or "White", empty to remain in the current state
Property Color As %String;

/// Brightness of the light: 0-100, empty to remain in the current state
Property Brightness As %Integer;

Storage Default
{
<Data name="SetLightDefaultData">
<Subscript>"SetLight"</Subscript>
<Value name="1">
<Value>State</Value>
</Value>
<Value name="2">
<Value>Color</Value>
</Value>
<Value name="3">
<Value>Brightness</Value>
</Value>
</Data>
<DefaultData>SetLightDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
