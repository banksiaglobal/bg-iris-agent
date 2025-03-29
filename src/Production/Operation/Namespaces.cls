Include Banksia

Class Production.Operation.Namespaces Extends Ens.BusinessOperation
{

Method ChangeNamespace(pInput As Production.Message.ChangeNamespaceIn, Output pOutput As Ens.StreamContainer) As %Status
{
    set response = {}
    set responseSC = $$$OK
    set currentNamespace = $namespace
    try{
        set $namespace = pInput.Name
    }catch ex {
        set stream = ##class(%Stream.GlobalCharacter).%New()
        set response = {"errorCode": 404, "message": "Conflict: Incorrect Namespace"}
        do response.%ToJSON(stream)
        set pOutput = ##class(Ens.StreamContainer).%New(stream)
        do pOutput.%Save(0)
        return responseSC
    }
    set response.status = "Namespace changed successfully"
    set response.namespace = pInput.Name
    set response.log = "New namespace: "_$namespace
    set stream = ##class(%Stream.GlobalCharacter).%New()
    do response.%ToJSON(stream)
    set pOutput = ##class(Ens.StreamContainer).%New(stream)
    do pOutput.%Save(0)
    quit responseSC
}

Method ListNamespaces(pInput As Production.Message.ListNamespacesIn, Output pOutput As Ens.StreamContainer) As %Status
{
    set statement=##class(%SQL.Statement).%New()
        set status=statement.%PrepareClassQuery("%SYS.Namespace","List")
        set resultset=statement.%Execute()
        set count = 1
        set namespacesArray = []
        while resultset.%Next() {
            set namespaceArray = ##class(%DynamicObject).%New()
            set namespaceArray.number = count
            set namespaceArray.name = resultset.%Get("Nsp")
            do namespacesArray.%Push(namespaceArray)
            set count = count + 1
            do ##Class(%SYS.Namespace).GetNSInfo(resultset.%Get("Nsp"), .info)
            set namespaceArray.directory = info("Directory")
            set namespaceArray.resource = info("Resource")
            set namespaceArray.readonly = info("ReadOnly")
            set namespaceArray.mounted = info("Mounted")
            set namespaceArray.status = info("Status")
            if ($namespace = resultset.%Get("Nsp")) {
                set namespaceArray.activenow = "yes"
            }
            else {
                set namespaceArray.activenow = "no"
            }
        }

    set stream=##class(%Stream.GlobalCharacter).%New()
    do namespacesArray.%ToJSON(stream)
    set pOutput=##class(Ens.StreamContainer).%New(stream)
    do pOutput.%Save(0)
    quit $$$OK
}

Method RunDynamicQuery(sql As %String, ByRef params, pRoutineName) As %SQL.StatementResult
{
    set statement = ##class(%SQL.Statement).%New()
	$$$ThrowOnError(statement.%Prepare(sql))
	if $get(pRoutineName)'="" merge routineParams=params(pRoutineName) kill params(pRoutineName)
	set resultSet = statement.%Execute(routineParams...)
	quit resultSet
}

XData MessageMap
{
<MapItems>
    <MapItem MessageType="Production.Message.ChangeNamespaceIn">
        <Method>ChangeNamespace</Method>
    </MapItem>   
        <MapItem MessageType="Production.Message.ListNamespacesIn">
        <Method>ListNamespaces</Method>
    </MapItem>   
</MapItems>
}

}
