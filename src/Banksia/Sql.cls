/// Helper methods to fix SQL Injections
Class Banksia.Sql
{

/// Initialise parameter storage before adding parameters
ClassMethod Init(pRoutine) As %String
{
	kill %banksiaSqlParams(pRoutine)
	quit ""
}

/// Add parameter to the parameter array
ClassMethod AddParam(pRoutine, pValue As %String) As %String
{
	set %banksiaSqlParams(pRoutine,$increment(%banksiaSqlParams(pRoutine)))=pValue
	quit " ? "
}

/// Run a query using parameter array
ClassMethod RunDynamicQuery(sql As %String, ByRef params, pRoutineName) As %SQL.StatementResult
{
    set statement = ##class(%SQL.Statement).%New()
	$$$ThrowOnError(statement.%Prepare(sql))
	if $get(pRoutineName)'="" merge routineParams=params(pRoutineName) kill params(pRoutineName)
	set resultSet = statement.%Execute(routineParams...)
	quit resultSet
}

}
