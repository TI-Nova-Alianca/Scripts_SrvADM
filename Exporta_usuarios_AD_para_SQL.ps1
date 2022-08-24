# Script para exportar usuarios do A.D. para o SQL, visando posteriores validacoes.
# Autor: Robert Koch
# Data:  10/12/2020
#
# Historico de alteracoes:

# Importa arquivos de funcoes via 'dot source' para que as funcoes possam ser usadas aqui.
. C:\util\Scripts\Function_Grava-Log.ps1

# -----------------------------------------------------------------
Grava-Log('Iniciando execucao')

# lista conteudo atual:  Get-aduser -filter * -Properties employeeid | Select-Object name, employeeid

# Busca matriculas no Matadados. Usa credencial de 'consultas' para conectar ao SQL
$SQLUser = "consultas"
$Password = "consultas" | ConvertTo-SecureString -AsPlainText -Force
$Password.MakeReadOnly()
$cred = New-Object System.Data.SqlClient.SqlCredential($SQLUser,$Password)
$connection = new-object System.Data.SqlClient.SQLConnection("Data Source=ServerSQL;Initial Catalog=TI");
$connection.credential = $cred
$connection.Open();
$query  = "delete USUARIOS_AD"
Grava-Log($query)
$cmd = new-object System.Data.SqlClient.SqlCommand($query, $connection);
$exec = $cmd.ExecuteNonQuery()

    $Users = @(get-aduser -Filter * -Properties name, employeeID)
    foreach ($User in $Users)
    {
        $query  = "insert into USUARIOS_AD ("
        $query += "SamAccountName, Enabled, EmployeeID"
        $query += ") values ("
        $query += "'" + $User.SamAccountName + "'"
        if ($User.Enabled)
        {
            $query += ",'S'"
        }
        else
        {
            $query += ",'N'"
        }
        $query += ",'" + $User.EmployeeID + "'"
        $query += ")"
        Grava-Log($query)
        $cmd = new-object System.Data.SqlClient.SqlCommand($query, $connection);
        $exec = $cmd.ExecuteNonQuery()

    }

Grava-Log('Finalizando execucao.')
