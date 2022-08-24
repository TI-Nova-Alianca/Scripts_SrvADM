# Script de coleta e envio de dados para o servidor Zabbix (monitoramneto) - Vinicola Nova Alianca
# Este script é disparado, inicialmente, pelo agendador de tarefas do Windows.
# Autor: Robert Koch
# Data: 28/11/2018
#
# Historico de alteracoes:
#

[xml]$xml = Get-Content -Path '\\192.168.1.3\c$\Espiao Cloud Monitor\Espiao Cloud Monitor\config\consulta.xml'
#$xml.NewDataSet.Table1.ultima_consulta
$ultexec = [datetime]::parseexact($xml.NewDataSet.Table1.ultima_consulta, 'dd/MM/yyyy HH:mm', $null)
$diferenca = (get-date) - $ultexec
#$diferenca.Minutes
& C:\Util\Scripts\Envia_para_Zabbix.ps1 Minutos_ult_exec_espiao $diferenca.Minutes 'SERVERPROTHEUS'
