/// Control user's light
Class Production.Operation.Light Extends EnsLib.REST.Operation
{

Method SetLight(pInput As Production.Message.SetLight, Output pOutput As Ens.StreamContainer) As %Status
{
    set tSC = $$$OK
    try {
        
        set json={"duration": 1,"fast":false}
        if pInput.State'="" set json.power=$zconvert(pInput.State,"l")
        if pInput.Color="Red" set json.color="kelvin:1500"
        if pInput.Color="White" set json.color="kelvin:3500"
        if pInput.Color="Cold" set json.color="kelvin:5000"
        if pInput.Brightness set json.brightness=pInput.Brightness/100

        $$$TRACE("Light request: "_json.%ToJSON())
 
        // Execute the call
        set tSC=..Adapter.Put(.tHttpResponse,"",json.%ToJSON())
        set statusCode = tHttpResponse.StatusCode
        // Return the response
        if $$$ISERR(tSC) && $isobject(tHttpResponse) && $isobject(tHttpResponse.Data) && tHttpResponse.Data.Size && statusCode >= 300 {
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
    <MapItem MessageType="Production.Message.SetLight">
        <Method>SetLight</Method>
    </MapItem>
</MapItems>
}

}
