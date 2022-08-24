# Script de coleta e envio de dados para o servidor Zabbix (monitoramento) - Vinicola Nova Alianca
#
# COMO ENCONTRA-SE NO SRV_ADM, PRECISA SER CHAMADO VIA COMANDO INVOKE, A PARTIR DE OUTRO SCRIPT.
#
# Autor: Robert Koch
# Data: 27/04/2020
#
# Historico de alteracoes:
#

# Verifica mensagens de incompatibilidade de versao do arquivo DBAPI no console do DBAccess
$ArqConsoleDBAccess = 'c:\Siga\DBAccess\dbconsole.log'
#$DbAccess_erro_versao_DBAPI = @(Get-Content $ArqConsoleDBAccess | Select-Object -last 10000 | Select-String -Pattern 'VERSION MISMATCH').Count
$DbAccess_erro_versao_DBAPI = @(Get-Content $ArqConsoleDBAccess | Select-String -Pattern 'VERSION MISMATCH').Count
& C:\Util\Scripts\Envia_para_Zabbix.ps1 DbAccess_erro_versao_DBAPI $DbAccess_erro_versao_DBAPI $env:COMPUTERNAME
