# Script de coleta e envio de dados para o servidor Zabbix (monitoramneto) - Vinicola Nova Alianca
# Este script é disparado, inicialmente, pelo agendador de tarefas do Windows.
# Autor: Robert Koch
# Data: 08/08/2015
#
# Historico de alteracoes:
# 03/04/2019 - Robert - Verificacao dos backups dos switches incorporada a este script (antes era um script externo)
#                     - Verificacao do Espiao NF-e incorporada a este script (antes era um script externo)
# 01/11/2019 - Robert - Migradas do ServerProtheus para ca as verificacoes de EDI Neogrid, importacao de XML e Webservice Walmart.
# 16/03/2020 - Robert - Criada verificacao de servicos automaticos que nao estejam em execucao.
# 04/05/2020 - Robert - Acrescentado GoogleUpdate a lista de servicos 'nao essenciais' do SvrMeta.
#                     - Acrescentado GoogleUpdate, MapsBroker e Biometria a lista de servicos 'nao essenciais' do SvrAdm.
# 23/07/2020 - Robert - Habilitada gravacao de arquivo de log.
# 11/10/2020 - Robert - Passa a pegar funcao de gravacao de log pronta em arquivo externo.
# 17/04/2022 - Robert - Desabilitadas chamadas de monitores do Protheus e SQLServer (migrados para Zabbix novo)
#

# Agenda tarefa no Windows - habilitar somente na primeira vez para criar o agendamento.
# $nomeScript = 'Envia_dados_para_Zabbix_30min'
# schtasks /create /TN $nomeScript /SC DAILY /ST 00:00 /RI 30 /DU 24:00 /RU "vinhos-alianca\Administrador" /TR "powershell -file c:\util\scripts\$nomeScript.ps1"


# Importa arquivos de funcoes via 'dot source' para que as funcoes possam ser usadas aqui.
. C:\util\Scripts\Function_Grava-Log.ps1

# -----------------------------------------------------------------
Grava-Log('Iniciando execucao')

# Verifica existencia e data dos arquivos de backup dos switches Dell
$switches = @('152','153','155','156','157','158','159','160')  # O switch de IP 192.168.1.154 nao foi instalado na ETA cfe. projeto original.
$comErro = ($switches | Measure-Object).Count
foreach ($switch in $switches)
{
#    $arqBkp = '\\192.168.1.12\Documentos\Informatica\infra\Config_rede\configuracao_switch_' + $switch + '.txt'
    $arqBkp = 'D:\Documentos\Informatica\INFRA\Config_rede\configuracao_switch_' + $switch + '.txt'
    #write-host $arqBkp
    if ((get-childitem $arqBkp | Measure-Object).count -eq 1)
    {
        #write-host 'Encontrei o arquivo'
        $lastWrite = (Get-Item $arqBkp).LastWriteTime
        $diasBackup = @(Get-Date).Subtract($lastWrite).TotalDays
        #write-host $lastWrite + '   ->   ' + $diasBackup + ' dias'
        if ($diasBackup -le 1)
        {
            $comErro --
        }
    }
}
& C:\Util\Scripts\Envia_para_Zabbix.ps1 switches_sem_backup $comErro $env:COMPUTERNAME
Grava-Log('Enviei switches')


#& C:\util\Scripts\Monitor_SQL.ps1
#Grava-Log('Enviei SQL')


# Executa remotamente um script local.
#Invoke-Command -ComputerName ServerProtheus -FilePath c:\Util\Scripts\Monitor_Protheus.ps1
#Grava-Log('Enviei protheus')


# Executa remotamente um script local.
Invoke-Command -ComputerName SrvMeta -FilePath c:\Util\Scripts\Monitor_Metadados.ps1
Grava-Log('Enviei metadados')


# Monitora ultima execucao do Espiao NF-e
[xml]$xml = Get-Content -Path '\\192.168.1.3\c$\Espiao Cloud Monitor\Espiao Cloud Monitor\config\consulta.xml'
$ultexec = [datetime]::parseexact($xml.NewDataSet.Table1.ultima_consulta, 'dd/MM/yyyy HH:mm', $null)
$diferenca = (get-date) - $ultexec
& C:\Util\Scripts\Envia_para_Zabbix.ps1 Minutos_ult_exec_espiao $diferenca.Minutes 'SERVERPROTHEUS'
Grava-Log('Enviei espiao')


# Habilitar somente durante a safra.
#& C:\util\Scripts\Monitor_Safra.ps1
#Grava-Log('Enviei safra')


# Verifica servicos com inicializacao automatica que nao estejam em execucao
#$servicosNaoIniciados = @(get-service | where -FilterScript {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' -and $_.Name -ne 'sppsvc' -and $_.Name -ne 'RemoteRegistry' -and $_.Name -ne 'gupdate' -and $_.Name -ne 'MapsBroker' -and $_.Name -ne 'WbioSrvc'}).Count
#& C:\Util\Scripts\Envia_para_Zabbix.ps1 ServicosNaoIniciados $servicosNaoIniciados $env:COMPUTERNAME
#Grava-Log('Enviei servicos srvadm')
#
#$servicosNaoIniciados = @(Invoke-Command -ComputerName ServerProtheus -scriptblock {get-service | where -FilterScript {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' -and $_.Name -ne 'sppsvc' -and $_.Name -ne 'RemoteRegistry'}}).Count
#& C:\Util\Scripts\Envia_para_Zabbix.ps1 ServicosNaoIniciados $servicosNaoIniciados 'SERVERPROTHEUS'
#Grava-Log('Enviei servicos serverprotheus')
#
#$servicosNaoIniciados = @(Invoke-Command -ComputerName SrvMeta -scriptblock {get-service | where -FilterScript {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' -and $_.Name -ne 'sppsvc' -and $_.Name -ne 'RemoteRegistry' -and $_.Name -ne 'gupdate' -and $_.Name -ne 'googleupdate'}}).Count
#& C:\Util\Scripts\Envia_para_Zabbix.ps1 ServicosNaoIniciados $servicosNaoIniciados 'SRVMETA'
#Grava-Log('Enviei servicos srvmeta')
#
#$servicosNaoIniciados = @(Invoke-Command -ComputerName SERVERSQL -scriptblock {get-service | where -FilterScript {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' -and $_.Name -ne 'sppsvc' -and $_.Name -ne 'RemoteRegistry'}}).Count
#& C:\Util\Scripts\Envia_para_Zabbix.ps1 ServicosNaoIniciados $servicosNaoIniciados 'SERVERSQL'
#Grava-Log('Enviei servicos serversql')


# Executa remotamente um script local.
Invoke-Command -ComputerName ServerSQL -FilePath c:\Util\Scripts\Monitor_DBAccess.ps1
Grava-Log('Enviei dbaccess')

Grava-Log('Finalizando execucao')
