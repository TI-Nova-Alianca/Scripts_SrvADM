
DESATIVADO EM 03/04/2019. PASSADO DIRETO PARA A ROTINA GERAL DE ENVIO PARA O ZABBIX

# Script de coleta e envio de dados para o servidor Zabbix (monitoramento) - Vinicola Nova Alianca
# Este script é disparado, inicialmente, pelo agendador de tarefas do Windows.
# Autor: Robert Koch
# Data: 08/08/2015
#
# Historico de alteracoes:
#

# Verifica backups dos switches
# O switch de IP 192.168.1.154 nao foi instalado na ETA cfe. projeto original.
$comErro = 8
$switches = @('152','153','155','156','157','158','159','160')
foreach ($switch in $switches)
{
    $arqBkp = 'D:\Documentos\Informatica\Infra\Config_rede\configuracao_switch_' + $switch + '.txt'
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
