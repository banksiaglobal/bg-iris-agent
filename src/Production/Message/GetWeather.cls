/// Get current weather based on coordinates
Class Production.Message.GetWeather Extends (Ens.Request, %JSON.Adaptor)
{

/// Lattitude of the location
Property Lattitude As %String;

/// Longitude of the location
Property Longitude As %String;

Storage Default
{
<Data name="GetWeatherDefaultData">
<Subscript>"GetWeather"</Subscript>
<Value name="1">
<Value>Lattitude</Value>
</Value>
<Value name="2">
<Value>Longitude</Value>
</Value>
</Data>
<DefaultData>GetWeatherDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
