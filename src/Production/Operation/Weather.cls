/// Get curent weather data
Class Production.Operation.Weather Extends EnsLib.REST.Operation
{

Method GetWeather(pInput As Production.Message.GetWeather, Output pOutput As Ens.StreamContainer) As %Status
{
    set tSC = $$$OK
    try {
        set tURL=..Adapter.URL_"?latitude="_pInput.Lattitude_"&longitude="_pInput.Longitude_"&current=temperature_2m,rain"
        set tSC=..Adapter.GetURL(tURL,.tHttpResponse)
        set statusCode = tHttpResponse.StatusCode
        if $$$ISERR(tSC) && $isobject(tHttpResponse) && $isobject(tHttpResponse.Data) && tHttpResponse.Data.Size && statusCode '= 200 {
            set errorMessage = tHttpResponse.Data.Read()
            set response = ##class(%DynamicObject).%New()
            do response.%Set("errorCode", statusCode)  
            do response.%Set("message", errorMessage)  
            set stream = ##class(%Stream.GlobalCharacter).%New()

            do response.%ToJSON(stream)
            set pOutput = ##class(Ens.StreamContainer).%New(stream)
            do pOutput.%Save(0)

            return response
        }
        quit:$$$ISERR(tSC)
        if $isobject(tHttpResponse) {
            if (tSC){                         
                set stream=##class(%Stream.GlobalCharacter).%New()
                set pOutput=##class(Ens.StreamContainer).%New(tHttpResponse.Data)
                do pOutput.%Save(0)
          }
       }
    } catch {
        set tSC=$$$SystemError
    }
    return tSC
}

XData MessageMap
{
<MapItems>
    <MapItem MessageType="Production.Message.GetWeather">
        <Method>GetWeather</Method>
    </MapItem>
</MapItems>
}

}
