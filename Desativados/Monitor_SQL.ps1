# Script de coleta e envio de dados para o servidor Zabbix (monitoramento) - Vinicola Nova Alianca
# Este script é disparado, inicialmente, pelo agendador de tarefas do Windows.
# Autor: Robert Koch
# Data: 15/10/2015
#
# Historico de alteracoes:
# 15/09/2016 - Robert - Passa a contemplar instancia do SQL 2014
#                     - Verificacoes de backups passam a usar a view dba.dbo.vminitor_backups do SQL2014.
# 04/04/2017 - Robert - Desabilitada verificacao de 'jobs desabilitados'
#                     - Verificacao de jobs com erro passa a desconsiderar jobs desabilitados.
# 18/11/2018 - Robert - Migrado para SrvAdm e ajustado para execucao remota
# 05/12/2018 - Robert - Incluida verificacao de transacoes demoradas.
# 22/08/2019 - Robert - Verificava jobs desabilitados (indevidamente) para ver se tinha erro de execucao.
# 02/09/2019 - Robert - Verificacao de jobs com erro passa a ignorar jobs sem agendamento (geralmente criados para um evento determinado e unico).
#

$verificacoes = @{
#    SQL_databases_sem_tempo_limite_backup = "select count (distinct instancia + name) from vmonitor_backups where horas_ultimo_backup is null or (tempo_maximo is null and horas_ultimo_backup != -1)"
#    SQL_databases_com_backup_atrasado     = "select count(*) from vmonitor_backups where tempo_maximo != -1 and horas_ultimo_backup > tempo_maximo"
#    SQL_jobs_com_erro                     = "select count (distinct job_id) from msdb..sysjobhistory s1 where run_status NOT IN (1, 4) and not exists (select * from msdb..sysjobhistory s2 where s2.job_id = s1.job_id and msdb.dbo.agent_datetime(s2.run_date, s2.run_time) > msdb.dbo.agent_datetime(s1.run_date, s1.run_time)) and exists (select * from msdb.dbo.sysjobs jobs where jobs.job_id = s1.job_id and jobs.enabled = 1)"
#    SQL_jobs_com_erro                     = "select count (distinct job_id) from msdb..sysjobhistory s1 where run_status NOT IN (1, 4) and not exists (select * from msdb..sysjobhistory s2 where s2.job_id = s1.job_id and msdb.dbo.agent_datetime(s2.run_date, s2.run_time) > msdb.dbo.agent_datetime(s1.run_date, s1.run_time)) and exists (select * from msdb.dbo.sysjobs jobs where jobs.job_id = s1.job_id and jobs.enabled = 1 and exists (select * from msdb.dbo.sysjobschedules sched where sched.job_id = jobs.job_id))"
#    SQL_transacoes_demoradas              = "select count (*) from sys.dm_tran_active_transactions where transaction_type = 1 and transaction_state = 2 and DATEDIFF (MINUTE, transaction_begin_time, GETDATE()) >= 10"
}

# Usa credencial de 'consultas' para conectar ao SQL
$SQLUser = "consultas"
$Password = "consultas" | ConvertTo-SecureString -AsPlainText -Force
$Password.MakeReadOnly()
$cred = New-Object System.Data.SqlClient.SqlCredential($SQLUser,$Password)


#ServerSQL
$connection = new-object System.Data.SqlClient.SQLConnection("Data Source=serverSQL;Initial Catalog=master");
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


#SrvMeta
$connection = new-object System.Data.SqlClient.SQLConnection("Data Source=SrvMeta;Initial Catalog=master");
$connection.credential = $cred
$connection.Open();
foreach ($h in $verificacoes.Keys) {
    $query = $($verificacoes.Item($h))
    $cmd = new-object System.Data.SqlClient.SqlCommand($query, $connection);
    $reader = $cmd.ExecuteReader()
    if ($reader.Read())
    {
        & C:\Util\Scripts\Envia_para_Zabbix.ps1 ${h} $reader.GetValue(0) 'SRVMETA'
    }
    $reader.Close()
}


#SERVER02
$connection = new-object System.Data.SqlClient.SQLConnection("Data Source=Server02;Initial Catalog=master");
$connection.credential = $cred
$connection.Open();
foreach ($h in $verificacoes.Keys) {
    $query = $($verificacoes.Item($h))
    $cmd = new-object System.Data.SqlClient.SqlCommand($query, $connection);
    $reader = $cmd.ExecuteReader()
    if ($reader.Read())
    {
        & C:\Util\Scripts\Envia_para_Zabbix.ps1 ${h} $reader.GetValue(0) 'SERVER02'
    }
    $reader.Close()
}


#SERVER17
$connection = new-object System.Data.SqlClient.SQLConnection("Data Source=Server17;Initial Catalog=master");
$connection.credential = $cred
$connection.Open();
foreach ($h in $verificacoes.Keys) {
    $query = $($verificacoes.Item($h))
    $cmd = new-object System.Data.SqlClient.SqlCommand($query, $connection);
    $reader = $cmd.ExecuteReader()
    if ($reader.Read())
    {
        & C:\Util\Scripts\Envia_para_Zabbix.ps1 ${h} $reader.GetValue(0) 'SERVER17'
    }
    $reader.Close()
}
