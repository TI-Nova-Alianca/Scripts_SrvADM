# Script de coleta e envio de dados para o servidor Zabbix (monitoramento) - Vinicola Nova Alianca
# Este script é disparado, inicialmente, pelo agendador de tarefas do Windows.
# Autor: Robert Koch
# Data: 27/01/2020
#
# Historico de alteracoes:
#

$verificacoes = @{
    SQL_ult_atu_med_continua_grau_F01 = "select DATEDIFF (MINUTE, (select max (HORA) FROM MEDICOES_CONTINUAS WHERE FILIAL = '01'), CURRENT_TIMESTAMP)"
}

# Usa credencial de 'consultas' para conectar ao SQL
$SQLUser = "consultas"
$Password = "consultas" | ConvertTo-SecureString -AsPlainText -Force
$Password.MakeReadOnly()
$cred = New-Object System.Data.SqlClient.SqlCredential($SQLUser,$Password)


#ServerSQL
$connection = new-object System.Data.SqlClient.SQLConnection("Data Source=serverSQL;Initial Catalog=BL01");
$connection.credential = $cred
$connection.Open();
foreach ($h in $verificacoes.Keys) {
    $query = $($verificacoes.Item($h))
    $cmd = new-object System.Data.SqlClient.SqlCommand($query, $connection);
    $reader = $cmd.ExecuteReader()
    if ($reader.Read())
    {
        & C:\Util\Scripts\Envia_para_Zabbix.ps1 ${h} $reader.GetValue(0) 'SERVERSQL'
    }
    $reader.Close()
}
