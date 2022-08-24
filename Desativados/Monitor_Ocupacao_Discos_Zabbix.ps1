# Script de coleta e envio de dados para o servidor Zabbix (monitoramento) - Vinicola Nova Alianca
# Este script é disparado, inicialmente, pelo agendador de tarefas do Windows.
# Autor: Robert Koch
# Data: 15/10/2015
#
# Historico de alteracoes:
#

$DiscoC = Get-WmiObject -Query "Select * from Win32_LogicalDisk where DriveType=3 and DeviceID = 'C:'"
$ocupacao_disco_C = ([math]::Round(($DiscoC.Size - $DiscoC.FreeSpace) * 100 / $DiscoC.Size, 2))
& C:\Util\Scripts\Envia_para_Zabbix.ps1 Win_disco_C_percent_ocup $ocupacao_disco_C $env:COMPUTERNAME

