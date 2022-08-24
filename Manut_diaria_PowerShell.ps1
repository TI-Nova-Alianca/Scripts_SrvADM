# Script de manutencao diaria do Server-ADM - Vinicola Nova Alianca
# Este script é disparado, inicialmente, pelo agendador de tarefas do Windows.
# Autor: Robert Koch
# Data: 2014
#
# Historico de alteracoes:
# 03/04/2019 - Robert - Script de backup dos switches Dell incorporado a este script (antes estava agendado no 192.168.1.5)
# 15/08/2019 - Robert - Alterado para limpar itens mais velhos que 03 dias, ajustado para limpar por pasta e não na raiz dos digitalizados, 
#                       pois uma pasta pode ficar mais que 03 dias sem receber arquivo.
#                     - Ajustado a forma de comentariar por bloco.
# 11/10/2020 - Robert - Passa a gravar log de execucao.
#

# Agendar tarefa no Windows - Selecione o trecho abaixo somente na primeira vez para criar o agendamento.
# $nomeScript = 'Manut_diaria_PowerShell'
# schtasks /create /TN $nomeScript /SC DAILY /ST 00:00 /RI 1400 /DU 24:00  /RU "vinhos-alianca\Administrador" /TR "powershell -file c:\util\scripts\$nomeScript.ps1"

# Importa arquivos de funcoes via 'dot source' para que as funcoes possam ser usadas aqui.
. C:\util\Scripts\Function_Grava-Log.ps1

Grava-Log('Iniciando execucao')


# Limpa arquivos antigos.
Grava-Log('Limpando arquivos antigos')
#Get-ChildItem 'd:\documentos\publico\'*.* -Recurse | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-90)} | remove-item -Recurse -force
Get-ChildItem 'd:\documentos\digitalizados\Administrativo\'*.* -Recurse | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-3)} | remove-item -recurse -force
Get-ChildItem 'd:\documentos\digitalizados\Comercial\'*.*      -Recurse | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-3)} | remove-item -recurse -force
Get-ChildItem 'd:\documentos\digitalizados\Logistica\'*.*      -Recurse | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-3)} | remove-item -recurse -force
Get-ChildItem 'd:\documentos\digitalizados\PCP\'*.*            -Recurse | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-3)} | remove-item -recurse -force
Get-ChildItem 'd:\documentos\digitalizados\Portaria\'*.*       -Recurse | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-3)} | remove-item -recurse -force
Get-ChildItem 'd:\documentos\digitalizados\RH\'*.*             -Recurse | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-3)} | remove-item -recurse -force


# Backup configuracao switches Dell
Grava-Log('Iniciando backup switches Dell')
$switches = @('152','153','155','156','157','158','159','160')  # O switch de IP 192.168.1.154 nao foi instalado na ETA cfe. projeto original.
$comandos = @('admin', 'alianca164', 'show running-config', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ')
foreach ($switch in $switches)
{
    Write-host 'Verificando switch '$switch
    Grava-Log('Switch ' + $switch)
    
    #Remove o arquivo existente para evitar erros de gravacao, ficando coisa antiga, etc.
#   $arqBkp = '\\192.168.1.12\Documentos\Informatica\infra\Config_rede\configuracao_switch_' + $switch + '.txt'
    $arqBkp = 'D:\Documentos\Informatica\INFRA\Config_rede\configuracao_switch_' + $switch + '.txt'
    Remove-Item $arqBkp

    $result = ''
    $socket = New-Object System.Net.Sockets.TCPClient -ArgumentList ('192.168.1.'+$switch), 23
    If ($Socket)
    {  $Stream = $Socket.GetStream()
        $Writer = New-Object System.IO.StreamWriter($Stream)
        $Buffer = New-Object System.Byte[] 1024
        $Encoding = New-Object System.Text.AsciiEncoding
        foreach ($cmd in $comandos)
        {
            $Writer.WriteLine($cmd)
            $Writer.Flush()
            # Aguarda um tempo pelo retorno do switch
            Start-sleep -Milliseconds 2000
        }
        While($Stream.DataAvailable) 
        {
            $Read = $Stream.Read($Buffer, 0, 1024) 
            $Result += ($Encoding.GetString($Buffer, 0, $Read))
        }
    }
    Else 
    {
        $Result = 'Erro ao conectar ao switch '+$switch
    }
    $Result | Out-File $arqBkp
}
Grava-Log('Backup switches Dell finalizado')

Grava-Log('Finalizando execucao')
