/// This is a generic IRIS service to connect agentic LLMs to the interoperability production
Class Banksia.IrisAgent.RestService Extends EnsLib.REST.Service
{

/// We will call this via Web Gateway to support HTTPS, so don't need a separate adapter
Parameter ADAPTER;

/// Our REST APIs will not use session
Parameter UseSession As BOOLEAN = 0;

/// Service host name will be part of the URL
Parameter EnsServicePrefix As STRING = "|";

/// Names a destination or destinations to which requests will be forwarded.
/// Could be processes or operations.
Property TargetConfigNames As %String(MAXLEN = 1000);

Parameter SETTINGS = "TargetConfigNames::selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/call/:operationName/:messageName" Method="POST" Call="Call" Cors="true"/>
    <Route Url="/call/:operationName/:messageName" Method="GET" Call="Call" Cors="true"/>
    <Route Url="/call/:operationName/:messageName" Method="DELETE" Call="Call" Cors="true"/>
    <Route Url="/call/:operationName" Method="POST" Call="Call" Cors="true"/>
    <Route Url="/call/:operationName" Method="GET" Call="Call" Cors="true"/>
    <Route Url="/call/:operationName" Method="DELETE" Call="Call" Cors="true"/>
    <Route Url="/openapi" Method="GET" Call="GetOpenApi" Cors="true"/>
    <Route Url="/createapikey" Method="GET" Call="CreateApiKey" Cors="true"/>
</Routes>
}

/// Call a particular process or operation
Method Call(pInput As %Library.AbstractStream, pOutput As %Library.AbstractStream, pOperationName As %String, pMessageName As %String = "")
{

    try {
        set continue = 1
        set tSC = ..ValidateApiKey(.continue)  
        if continue=0 {
            return tSC  
        }

		set isOperationFound=0
        for i=1:1:$length(..TargetConfigNames,",") { 
            set tOne=$zstrip($piece(..TargetConfigNames,",",i),"<>W")  
            continue:""=tOne  
            if tOne=pOperationName set isOperationFound=1 
        }

        if 'isOperationFound return $$$ERROR($$$GeneralError,"Operation not found")

        set request = $classmethod(pMessageName, "%New")
        if pInput.Size > 0 do request.%JSONImport(pInput)
        set sc = ..SendRequestSync(pOperationName, request, .response, 2)
        if $$$ISERR(sc) return sc
        do pOutput.CopyFrom(response.Stream)

        set responseString = pOutput.Read()
        set responseJSON = {}
        set responseJSON = $classmethod("%Library.DynamicObject", "%FromJSON", responseString)
            try {
            set responseJSON = $classmethod("%Library.DynamicObject", "%FromJSON", responseString)

            if responseJSON.%IsDefined("errorCode") && (responseJSON.%GetTypeOf("errorCode")'="object") {
                set errorCode = responseJSON.%Get("errorCode")
                set errorMessage = responseJSON.%Get("message",, "json")
                return ..ReportHttpStatusCode(errorCode)
            }

        } catch ex {
            return ex.AsStatus()
        }
    } catch(e) {
        return e.AsStatus()
    }
    return $$$OK
}

/// Generate api key
Method CreateApiKey(pInput As %Library.AbstractStream, pOutput As %Library.AbstractStream) As %Status
{
    set sc = $$$OK
    try {
        set ApiKey=$get(^SecretApiKey)
        if ApiKey="" {
            set ApiKey=##class(%PopulateUtils).StringMin(64,64)
            set ApiKey=$$$BASE64URLENCODE(ApiKey)
            set ^SecretApiKey=ApiKey
            set result = {
                "Api Key status": "Api key has been succesfully created. Check it in Portal -> System -> Globals by SecretApiKey name."
            }
        }
        else {
            set result = {
                "Api Key status": "Api key has already been created. Check it in Portal -> System -> Globals by SecretApiKey name."
            }
        }
    }
    catch e {
        return e.AsStatus()
    }
    do result.%ToJSON(pOutput)
    return sc
}

ClassMethod ValidateApiKey(ByRef pContinue As %Boolean) As %Status
{
  set tSC = $$$OK
    set ApiKeyGlobal=$get(^SecretApiKey)
    #dim request as %CSP.Request 
    set request = %request
    set apiKeyRequest = ##class(%REST.Impl).%GetHeader("X-Api-Key")
    if (ApiKeyGlobal = "")
    {    
        set pContinue = 0
        return ..ReportHttpStatusCode(..#HTTP401UNAUTHORIZED, "Your API key is not set. Please get your API key.")
    }
    if (apiKeyRequest =""){
        set pContinue = 0
        return ..ReportHttpStatusCode(..#HTTP401UNAUTHORIZED, "No API key provided")
        set tSC=$$$ERROR(..#HTTP401UNAUTHORIZED)
    }
    if (apiKeyRequest'=ApiKeyGlobal){
        set pContinue = 0
        return ..ReportHttpStatusCode(..#HTTP401UNAUTHORIZED, "Invalid API key")
        set tSC=$$$ERROR(..#HTTP401UNAUTHORIZED)
    }
    quit tSC
}

/// Generate OpenAPI definition of this service for LLM tools to use
Method GetOpenApi(pInput As %Library.AbstractStream, pOutput As %Library.AbstractStream)
{
    set urlHost = $select(%request.Secure:"https://", 1:"http://")_%request.GetCgiEnv("HTTP_HOST")
    set ConfigItem = ##class(Ens.Config.Production).OpenItemByConfigName(..%ConfigName)
    set api = {
        "openapi": "3.1.0",
        "info": {
            "title": (..%ConfigName),
            "description": (ConfigItem.Comment),
            "version": "1.0.0"
        },
        "servers": [
            {
                "url": (urlHost_$piece(%request.URL, "/", 1, *-1))
            }
        ],
        "paths": {}
    }
    for i = 1:1:$length(..TargetConfigNames, ",") { 
        set target = $zstrip($piece(..TargetConfigNames, ",", i), "<>W")  
        if target = "" {
            quit  
        }
        set ConfigItem = ##class(Ens.Config.Production).OpenItemByConfigName(target)
        set messageClassList = $classmethod(ConfigItem.ClassName, "GetMessageList")
        for j = 1:1:$listlength(messageClassList) {
            set messageClass = $list(messageClassList, j)
            set MessageClassDefinition = ##class(%Dictionary.ClassDefinition).%OpenId(messageClass)
            set pathDefinition = {
                "post": {
                    "operationId": (target_$translate(messageClass, ".")),
                    "summary": (ConfigItem.Comment),
                    "description": (MessageClassDefinition.Description)
                }
            }
            if MessageClassDefinition.Properties.Count() > 0 {
                set properties = {}
                for pi = 1:1:MessageClassDefinition.Properties.Count() {
                    set Property = MessageClassDefinition.Properties.GetAt(pi)
                    set property = {
                        "type": "string",
                        "description": (Property.Description)
                    }
                    do properties.%Set(Property.Name, property)
                }
                set pathDefinition.post.requestBody = {
                    "required": true,
                    "content": {
                        "application/json": {
                            "schema": {
                                "type": "object",
                                "properties": (properties)
                            }
                        }
                    }
                }
            }
            do api.paths.%Set("/call/"_target_"/"_messageClass, pathDefinition) 
        }
    }

    do api.%ToJSON(pOutput)
    quit $$$OK
}

/// Add connections from TargetConfigNames
ClassMethod OnGetConnections(Output pArray As %String, pItem As Ens.Config.Item)
{
	do ##super(.pArray,pItem)
	if pItem.GetModifiedSetting("TargetConfigNames",.tValue) {
		for i=1:1:$length(tValue,",") { set tOne=$zstrip($piece(tValue,",",i),"<>W")  continue:""=tOne  set pArray(tOne)="" }
	}
}

}
