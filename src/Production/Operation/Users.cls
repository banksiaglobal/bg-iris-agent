Include Banksia

Class Production.Operation.Users Extends Ens.BusinessOperation
{

Method ListUsers(pInput As Production.Message.ListUsersIn, Output pOutput As Ens.StreamContainer) As %Status
{
    set tSC = $$$OK
    set users = []

    set sqlString=$$$sqlInit_"SELECT users.name, users.fullname, users.createdatetime, users.roles FROM Security.Users"
    if pInput.NameSearch'="" {
        set sqlString=sqlString_" WHERE LOWER(users.name) LIKE LOWER("_$$$sqlAdd("%"_pInput.NameSearch_"%")_") OR LOWER(users.fullname) LIKE LOWER("_$$$sqlAdd("%"_pInput.NameSearch_"%")_")"
    }

   // Temporary code to switch to the correct namespace
    set currentNamespace = $namespace
    set $namespace = "%SYS"

    // Ususally we will do
    // Set resultSet = ##class(Banksia.Sql).RunDynamicQuery(sqlString,$$$sqlParams)
    // However, because we switch namespaces we can't do that, there is no Banksia class in %SYS
    // So we have to copy-paste this method to current class
    set resultSet = ..RunDynamicQuery(sqlString,$$$sqlParams)

    while resultSet.%Next() {
        set user = ##class(%DynamicObject).%New()
        do user.%Set("Name", resultSet.%Get("name"))
        do user.%Set("FullName", resultSet.%Get("fullname"))
        do user.%Set("CreateDateTime", resultSet.%Get("createdatetime"))
        do user.%Set("Roles", resultSet.%Get("roles"))

        set matcher = ##class(%Regex.Matcher).%New("[\u0001\u0006\u0018\u0014\n]", user.Roles)
        set user.Roles = matcher.ReplaceAll("")


        set user.CreateDateTime = $piece(user.CreateDateTime, ",", 1)
        set user.CreateDateTime = $zdatetime(user.CreateDateTime, 1, 1, 9)
        do users.%Push(user)
    }

    set $namespace = currentNamespace
    set stream=##class(%Stream.GlobalCharacter).%New()
    do users.%ToJSON(stream)
    set pOutput=##class(Ens.StreamContainer).%New(stream)
    do pOutput.%Save(0)
    return $$$OK
}

Method NewUser(pInput As Production.Message.NewUserIn, Output pOutput As Ens.StreamContainer) As %Status
{
    set response = {}
    set responseSC = $$$OK

    set isUserExists = ..checkUserExists(pInput.Name)
    if isUserExists {
        set stream = ##class(%Stream.GlobalCharacter).%New()
        set response = {"errorCode": 409, "message": "Conflict: Username already exists"}
        do response.%ToJSON(stream)
        set pOutput = ##class(Ens.StreamContainer).%New(stream)
        do pOutput.%Save(0)
        quit responseSC
    }

    // Check if username is valid
    if '##class(%Regex.Matcher).%New("^[a-zA-Z0-9_]+$", pInput.Name).Match() {
        quit $$$ERROR(400, "Invalid username format")
    }

    try {
        set sql = "CREATE USER "_pInput.Name_" IDENTIFY BY "_pInput.Password
        set tStatement = ##class(%SQL.Statement).%New()
        set qStatus = tStatement.%Prepare(sql)
        if 'qStatus {
            set response={"error":-500}
            $$$ThrowOnError($$$ERROR($$$GeneralError, "User cannot be saved 1"_qStatus))
        }
        set rStatus = tStatement.%Execute()
        if 'rStatus {
            set response={"error":-500}
            $$$ThrowOnError($$$ERROR($$$GeneralError, "User cannot be saved 2"_rStatus))
        }
        set response.CreateUsername = pInput.Name
        set response.log ="User created successfully"
    }
    catch ex {
        if response.error="" set response.error=-500
        set response.errorText=$system.Status.GetErrorText(ex.AsStatus())
        set responseSC = $system.Status.GetErrorText(ex.AsStatus())
    }
    set stream = ##class(%Stream.GlobalCharacter).%New()
    do response.%ToJSON(stream)
    set pOutput = ##class(Ens.StreamContainer).%New(stream)
    do pOutput.%Save(0)
    quit responseSC
}

Method DeleteUserByName(pInput As Production.Message.DeleteUserIn, Output pOutput As Ens.Response) As %Status
{
    set tSC = $$$OK
    set response = {}
    set IsUserExists = ..checkUserExists(pInput.Name)
    if 'IsUserExists {
        set stream = ##class(%Stream.GlobalCharacter).%New()
        set response = {"errorCode": 404, "message": "Conflict: User does not exist"}
        do response.%ToJSON(stream)
        set pOutput = ##class(Ens.StreamContainer).%New(stream)
        do pOutput.%Save(0)
        quit tSC
    }

    /// Temporary code to switch to User with correct permissions
    set tSC = $system.Security.Login("_SYSTEM", "SYS")
    if $$$ISERR(tSC) {
        set response.status = 403
        set response = {"error": "Authentication failed"}
        do pOutput.Write(response.%ToJSON())
        quit $$$ERROR($$$GeneralError, "Authentication failed")
        }

    
    set sqlQuery = "DROP USER IF EXISTS "_pInput.Name
    try {
        set stmt = ##class(%SQL.Statement).%New()
        set result = stmt.%Prepare(sqlQuery)
        set result = stmt.%Execute()
        if result '= $$$OK {
            set tSC = $$$ERROR($$$GeneralError, "Unable to delete user")
            quit
        }
    } catch ex {
        write "Exception: "_ex.Message, !
        set tSC = $$$ERROR($$$GeneralError, "Unable to delete user")
        quit
    }
    
    set response.Username = pInput.Name
    set response.log ="User deleted successfully"
    set stream = ##class(%Stream.GlobalCharacter).%New()
    do response.%ToJSON(stream)
    set pOutput = ##class(Ens.StreamContainer).%New(stream)
    do pOutput.%Save(0)
    return $$$OK
}

Method checkUserExists(pName As %String) As %Boolean
{
    set sqlString=$$$sqlInit_"SELECT users.name FROM Security.Users"
    if pName'="" {
        set sqlString=sqlString_" WHERE LOWER(users.name) LIKE LOWER("_$$$sqlAdd("%"_pName_"%")_")"
    }
    set currentNamespace = $namespace
    set $namespace = "%SYS"
   
    set resultSet = ..RunDynamicQuery(sqlString, $$$sqlParams)
    set $namespace = currentNamespace
    if resultSet.%Next() {
        return 1
    } else {
        return 0    
    }
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
    <MapItem MessageType="Production.Message.ListUsersIn">
        <Method>ListUsers</Method>
    </MapItem> 
    <MapItem MessageType="Production.Message.NewUserIn">
        <Method>NewUser</Method>
    </MapItem>
    <MapItem MessageType="Production.Message.DeleteUserIn">
        <Method>DeleteUserByName</Method>
    </MapItem>
</MapItems>
}

}
