ROUTINE Banksia [Type=INC]
#define sqlPlace $TR($STACK($STACK,"PLACE"),"+1234567890")
#define sqlInit ##class(Banksia.Sql).Init($$$sqlPlace)
#define sqlAdd(%p) ##class(Banksia.Sql).AddParam($$$sqlPlace,%p)
#define sqlAddList(%p) ##class(Banksia.Sql).AddParam($$$sqlPlace,$listfromstring($tr(%p,"'""")))
#define sqlParams .%banksiaSqlParams,$$$sqlPlace
#define sqlStrip(%p) $ZSTRIP(%p,"*E'L'U")