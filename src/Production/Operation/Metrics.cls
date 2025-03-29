Include Banksia

Class Production.Operation.Metrics Extends Ens.BusinessOperation
{

Method ListSystemProfiles(pInput As Production.Message.ListSystemProfilesIn, Output pOutput As Ens.StreamContainer) As %Status
{
    set profiles = []
    set responseSC = $$$OK
    set file = ##class(%Library.File).%New("/etc/passwd")
    set status = file.Open("R")
    if status '= 1 {
        write "Error opening file: "
    }
    try {
        while ('file.AtEnd) {
            set line = file.ReadLine()
            set profileArray = ##class(%DynamicObject).%New()
            set profileArray.username = $piece(line, ":", 1)
            set profileArray.UID = $piece(line, ":", 3)
            set profileArray.GID = $piece(line, ":", 4)
            set profileArray.GECOS = $piece(line, ":", 5)
            set profileArray.homedirectory = $piece(line, ":", 6)
            set profileArray.shell = $piece(line, ":", 7)
            do profiles.%Push(profileArray)
        }
        do file.Close()
        }
    catch ex {
        if profiles.error="" set profiles.error=-500
        set profiles.errorText=$system.Status.GetErrorText(ex.AsStatus())
        set responseSC = $system.Status.GetErrorText(ex.AsStatus())
    }
    set stream=##class(%Stream.GlobalCharacter).%New()
    if pInput.UsernameSearch'="" {
        set foundProfiles = []
        set iterator=profiles.%GetIterator()
        while iterator.%GetNext(.key,.val) {
            if $find($zconvert(val.username,"l"), $zconvert(pInput.UsernameSearch,"l")) {
                do foundProfiles.%Push(val)
            }
        }
        do foundProfiles.%ToJSON(stream)
    }
    else {
        do profiles.%ToJSON(stream)
    }
    set pOutput=##class(Ens.StreamContainer).%New(stream)
    do pOutput.%Save(0)
    return responseSC
}

Method ListLogs(pInput As Production.Message.ListLogsIn, Output pOutput As Ens.StreamContainer) As %Status
{
    set logs = []
    set responseSC = $$$OK
    set file = ##class(%Library.File).%New("/usr/irissys/csp/bin/CSP.log")
    set status = file.Open("R")
    if status '= 1 {
        write "Error opening file"
    }
    try {
        while ('file.AtEnd) {
            set line = file.ReadLine()
            set logArray = ##class(%DynamicObject).%New() 
            set logArray.log = line
            do logs.%Push(logArray)
        }
        do file.Close()
    }
    catch ex {
        if logs.error="" set logs.error=-500
        set logs.errorText=$system.Status.GetErrorText(ex.AsStatus())
        set responseSC = $system.Status.GetErrorText(ex.AsStatus())
    }
    set stream=##class(%Stream.GlobalCharacter).%New()
    if pInput.LogSearch'="" {
        set foundLoges = []
        set iterator=logs.%GetIterator()
        while iterator.%GetNext(.key,.val) {
            if $find($zconvert(val.log,"l"), $zconvert(pInput.LogSearch,"l")) {
                do foundLoges.%Push(val)
            }
        }
        do foundLoges.%ToJSON(stream)
    }
    else {
        do logs.%ToJSON(stream)
    }
    set pOutput=##class(Ens.StreamContainer).%New(stream)
    do pOutput.%Save(0)
    return responseSC
}

Method ListMessages(pInput As Production.Message.ListMessagesIn, Output pOutput As Ens.StreamContainer) As %Status
{
    set messages = []
    set responseSC = $$$OK
    set file = ##class(%Library.File).%New("/usr/irissys/mgr/messages.log")
    set status = file.Open("R")
    if status '= 1 {
        write "Error opening file"
    }
    try {
        while ('file.AtEnd) {
        set line = file.ReadLine()
        if (($extract(line, 3, 3) = "/") && ($extract(line, 6, 6) = "/")) {
            set messageArray = ##class(%DynamicObject).%New()
            set messageArray.timestamp = $piece(line, " ", 1)
            set messageArray.code = $piece(line, " ", 2)
            set messageArray.event = $piece(line, " ", 4)
            set messageArray.message = $piece(line, " ", 5,*-1)}
            do messages.%Push(messageArray)
        }
        do file.Close()}
    catch ex {
        if messages.error="" set messages.error=-500
        set messages.errorText=$system.Status.GetErrorText(ex.AsStatus())
        set responseSC = $system.Status.GetErrorText(ex.AsStatus())
    }    
    set stream=##class(%Stream.GlobalCharacter).%New()
    if pInput.MessageSearch'="" {
        set foundMessagess = []
        set iterator=messages.%GetIterator()
        while iterator.%GetNext(.key,.val) {
            if $find($zconvert(val.message,"l"), $zconvert(pInput.MessageSearch,"l")) {
                do foundMessagess.%Push(val)
            }
        }
        do foundMessagess.%ToJSON(stream)
    }
    else {
        do messages.%ToJSON(stream)
    }
    set pOutput=##class(Ens.StreamContainer).%New(stream)
    do pOutput.%Save(0)
    return responseSC
}

Method ListErrors(pInput As Production.Message.ListErrorsIn, Output pOutput As Ens.StreamContainer) As %Status
{
    set errors = []
    set responseSC = $$$OK
    set file = ##class(%Library.File).%New("/usr/irissys/httpd/logs/error.log")
    set status = file.Open("R")
    if status '= 1 {
        write "Error opening file: "
    }
    try {
        while ('file.AtEnd) {
        set line = file.ReadLine()
        if ($extract(line, 1, 1) = "[") {
            set errorArray = ##class(%DynamicObject).%New() 
            set errorArray.timestamp = $piece(line, "]", 1)
            set errorArray.timestamp = $piece(errorArray.timestamp, "[", 2)
            set errorArray.status = $piece(line, "]", 2)
            set errorArray.status = $piece(errorArray.status, "[", 2)
            set errorArray.pidtid = $piece(line, "[", 4, *)
            set errorArray.pidtid = $piece(errorArray.pidtid, "]", 1)
            set errorArray.message = $piece(line, "]", 4, *)}
            do errors.%Push(errorArray)
        }
        do file.Close()
    }
    catch ex {
        if errors.error="" set errors.error=-500
        set errors.errorText=$system.Status.GetErrorText(ex.AsStatus())
        set responseSC = $system.Status.GetErrorText(ex.AsStatus())
    }
    set stream=##class(%Stream.GlobalCharacter).%New()
    if pInput.ErrorSearch'="" {
        set foundErrors = []
        set iterator=errors.%GetIterator()
        while iterator.%GetNext(.key,.val) {
            if $find($zconvert(val.message,"l"), $zconvert(pInput.ErrorSearch,"l")) {
                do foundErrors.%Push(val)
            }
        }
        do foundErrors.%ToJSON(stream)
    }
    else {
        do errors.%ToJSON(stream)
    }
    set pOutput=##class(Ens.StreamContainer).%New(stream)
    do pOutput.%Save(0)
    return responseSC
}

Method ListServices(pInput As Production.Message.ListServicesIn, Output pOutput As Ens.StreamContainer) As %Status
{
    set services = []
    set responseSC = $$$OK
    set sqlString=$$$sqlInit_"SELECT services.id, services.description, services.name FROM Security.Services"
    if pInput.DescriptionSearch'="" {
        set sqlString=sqlString_" WHERE LOWER(services.description) LIKE LOWER("_$$$sqlAdd("%"_pInput.DescriptionSearch_"%")_") OR LOWER(services.name) LIKE LOWER("_$$$sqlAdd("%"_pInput.DescriptionSearch_"%")_")"
    }

    // Temporary code to switch to the correct namespace
    set currentNamespace = $namespace
    set $namespace = "%SYS"
    set resultSet = ..RunDynamicQuery(sqlString,$$$sqlParams)
    try {
        while resultSet.%Next() {
            set service = ##class(%DynamicObject).%New()
            set service.id = resultSet.%Get("id")
            set service.description = resultSet.%Get("description")
            set service.name = resultSet.%Get("name")
            do services.%Push(service)
        }
    }
    catch ex {
        if services.error="" set services.error=-500
        set services.errorText=$system.Status.GetErrorText(ex.AsStatus())
        set responseSC = $system.Status.GetErrorText(ex.AsStatus())
    }
    set $namespace = currentNamespace
    set stream=##class(%Stream.GlobalCharacter).%New()
    do services.%ToJSON(stream)
    set pOutput=##class(Ens.StreamContainer).%New(stream)
    do pOutput.%Save(0)
    return responseSC
}

Method ListRoles(pInput As Production.Message.ListRolesIn, Output pOutput As Ens.StreamContainer) As %Status
{
    set roles = []
    set responseSC = $$$OK

    set sqlString=$$$sqlInit_"SELECT roles.id, roles.description, roles.name FROM Security.Roles"
    if pInput.DescriptionSearch'="" {
        set sqlString=sqlString_" WHERE LOWER(roles.description) LIKE LOWER("_$$$sqlAdd("%"_pInput.DescriptionSearch_"%")_") OR LOWER(roles.name) LIKE LOWER("_$$$sqlAdd("%"_pInput.DescriptionSearch_"%")_")"
    }

    // Temporary code to switch to the correct namespace
    set currentNamespace = $namespace
    set $namespace = "%SYS"
    set resultSet = ..RunDynamicQuery(sqlString,$$$sqlParams)
    try {
        while resultSet.%Next() {
            set role = ##class(%DynamicObject).%New()
            set role.id = resultSet.%Get("id")
            set role.description = resultSet.%Get("description")
            set role.name = resultSet.%Get("name")
            do roles.%Push(role)
        }
    }
    catch ex {
        if roles.error="" set roles.error=-500
        set roles.errorText=$system.Status.GetErrorText(ex.AsStatus())
        set responseSC = $system.Status.GetErrorText(ex.AsStatus())
    }
    set $namespace = currentNamespace
    set stream=##class(%Stream.GlobalCharacter).%New()
    do roles.%ToJSON(stream)
    set pOutput=##class(Ens.StreamContainer).%New(stream)
    do pOutput.%Save(0)
    return responseSC
}

Method ListApplications(pInput As Production.Message.ListApplicationsIn, Output pOutput As Ens.StreamContainer) As %Status
{
    set applications = []
    set responseSC = $$$OK

    set sqlString=$$$sqlInit_"SELECT applications.id FROM Security.Applications"
    if pInput.NameSearch'="" {
        set sqlString=sqlString_" WHERE LOWER(applications.id) LIKE LOWER("_$$$sqlAdd("%"_pInput.NameSearch_"%")_")"
    }

    // Temporary code to switch to the correct namespace
    set currentNamespace = $namespace
    set $namespace = "%SYS"
    set resultSet = ..RunDynamicQuery(sqlString,$$$sqlParams)
    try {
        while resultSet.%Next() {
            set application = ##class(%DynamicObject).%New()
            set application.name = resultSet.%Get("id")
            do applications.%Push(application)
        }
    }
    catch ex {
        if applications.error="" set applications.error=-500
        set applications.errorText=$system.Status.GetErrorText(ex.AsStatus())
        set responseSC = $system.Status.GetErrorText(ex.AsStatus())
    }
    set $namespace = currentNamespace
    set stream=##class(%Stream.GlobalCharacter).%New()
    do applications.%ToJSON(stream)
    set pOutput=##class(Ens.StreamContainer).%New(stream)
    do pOutput.%Save(0)
    return responseSC
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
    <MapItem MessageType="Production.Message.ListSystemProfilesIn">
        <Method>ListSystemProfiles</Method>
    </MapItem> 
    <MapItem MessageType="Production.Message.ListLogsIn">
        <Method>ListLogs</Method>
    </MapItem>
    <MapItem MessageType="Production.Message.ListMessagesIn">
        <Method>ListMessages</Method>
    </MapItem>
    <MapItem MessageType="Production.Message.ListErrorsIn">
        <Method>ListErrors</Method>
    </MapItem>
    <MapItem MessageType="Production.Message.ListServicesIn">
        <Method>ListServices</Method>
    </MapItem>
    <MapItem MessageType="Production.Message.ListRolesIn">
        <Method>ListRoles</Method>
    </MapItem>
    <MapItem MessageType="Production.Message.ListApplicationsIn">
        <Method>ListApplications</Method>
    </MapItem>
</MapItems>
}

}
