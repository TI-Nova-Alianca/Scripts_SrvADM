    $SQLUser = "consultas"
    $pwdSQL = "consultas" | ConvertTo-SecureString -AsPlainText -Force
    $pwdSQL.MakeReadOnly()
    $credSQL = New-Object System.Data.SqlClient.SqlCredential($SQLUser,$pwdSQL)
    $connectionSQL = new-object System.Data.SqlClient.SQLConnection("Data Source=SrvMeta;Initial Catalog=SIRH");
    $connectionSQL.credential = $credSQL
    $connectionSQL.Open();

$SQLQuery = "exec VA_SP_HORARIOS_PARA_AD @in_Pessoa=1001632, @in_DiaSolicitado=null"
$SQLCmd = new-object System.Data.SqlClient.SqlCommand($SQLQuery, $ConnectionSQL);
$SqlCmd.CommandTimeout = 120;
$ConnectionSQL.Open();
#$ConnectionSQL.close();
$SQLReader = $SQLCmd.ExecuteReader()

# Monta array com os dados retornados, para poder fechar a query, senao nao consigo gerar UPDATE posteriormente.
#$Registros = [System.Collections.ArrayList]@()
while ($SQLReader.Read()) {
#    $reg = @($SQLReader.GetValue(0), $SQLReader.GetValue(1), $SQLReader.GetValue(2), $SQLReader.GetValue(3), $SQLReader.GetValue(4), $SQLReader.GetValue(5)) #, $SQLReader.GetValue(6))
#    $Registros.Add($reg) #> $null
    write-host $SQLReader.GetValue(0) + $SQLReader.GetValue(1) + $SQLReader.GetValue(2) + $SQLReader.GetValue(3) + $SQLReader.GetValue(4) + $SQLReader.GetValue(5) + $SQLReader.GetValue(6)
}
$SQLReader.Close()
