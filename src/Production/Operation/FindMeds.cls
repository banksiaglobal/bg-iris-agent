Class Production.Operation.FindMeds Extends EnsLib.REST.Operation
{

Method ListMeds(pInput As Production.Message.ListMedsIn, Output pOutput As Ens.StreamContainer) As %Status
{
    set tSC = $$$OK
    try {

        if $find(pInput.Name, " ") '= 0 {
            set Name = $replace(pInput.Name," ","+")
        } else {
            set Name = pInput.Name
        }
        set tURL=..Adapter.URL_"?search=brand_name:"_Name_"*&limit=20"
        
        if pInput.Limit '= "" {
            set tURL=..Adapter.URL_"?search=brand_name:"_Name_"*&limit="_pInput.Limit

        }
        set tSC=..Adapter.GetURL(tURL,.tHttpResponse)
        set statusCode = tHttpResponse.StatusCode
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
    <MapItem MessageType="Production.Message.ListMedsIn">
        <Method>ListMeds</Method>
    </MapItem>
</MapItems>
}

}
