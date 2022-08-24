# Script de coleta e envio de dados para o servidor Zabbix (monitoramento) - Vinicola Nova Alianca
# Este script é disparado, inicialmente, pelo agendador de tarefas do Windows.
# Autor: Robert Koch
# Data: 03/04/2019
#
# Historico de alteracoes:
#

#& C:\util\Scripts\Monitor_Metadados_Zabbix.ps1
# Verifica estado dos servicos do Metadados
$Metadados_servico_Agendador = if (@(get-service -name 'SrvMetaAgendador').Status -eq 'Running') {1} else {0}
$Metadados_servico_Dimep     = if (@(get-service -name 'SrvDimepCom').Status      -eq 'Running') {1} else {0}

# Verifica se o arquivo de log do agendador tem registros na data de hoje.
$Metadados_log_agendador = 0
$ArqLogAgendador = 'C:\Meta\rhsis\MetaAgendadorServico.log'
if ((gci $ArqLogAgendador).LastWriteTime -ge (Get-Date).AddDays(-1))  # Somente se teve atualizacao recente
{
    $DataDeHoje = (Get-Date -Format dd).ToString() + '/' + (Get-Date -Format MM).ToString() + '/' + (Get-Date -Format yyyy).ToString()
    $Metadados_log_agendador = @(Get-Content $ArqLogAgendador | Select-String -SimpleMatch -Pattern $DataDeHoje).Count
}

# Este script deve estar presente no SrvMeta. Nao achei forma de chamar ele do SrvAdm dentro de um 'Invoke-Command'.
& c:\Util\Scripts\Envia_para_Zabbix.ps1 Metadados_servico_Agendador $Metadados_servico_Agendador $env:COMPUTERNAME
& c:\Util\Scripts\Envia_para_Zabbix.ps1 Metadados_servico_Dimep $Metadados_servico_Dimep $env:COMPUTERNAME
& c:\Util\Scripts\Envia_para_Zabbix.ps1 Metadados_log_agendador $Metadados_log_agendador $env:COMPUTERNAME
