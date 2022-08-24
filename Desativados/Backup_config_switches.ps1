


MIGRADO PARA DENTRO DO SCRIPT DE MANUTENCAO DIARIA EM 03/04/2019


# Cooperativa Nova Aliança
# Script para gerar backup da configuracao dos switches de rede
# Autor: Robert Koch
# Data: 18/06/2015
#
# Historico de alteracoes:
#

# Agenda tarefa no Windows - habilitar somente na primeira vez para criar o agendamento.
#$nomeScript = 'Backup_config_switches'
#$AcaoGatilho = New-ScheduledTaskAction -execute "powershell" -argument ("-nologo -noprofile -noninteractive c:\util\scripts\" + $nomeScript + ".ps1")
#$Gatilho = New-ScheduledTaskTrigger -Once -At 00:00AM 
#Register-ScheduledTask -TaskName $nomeScript -Trigger $Gatilho -Action $AcaoGatilho -description Backup_config_switches -User "NT AUTHORITY\SYSTEM" -RunLevel 1
#$Gatilho.RepetitionInterval = (New-TimeSpan -Days 1)
#$Gatilho.RepetitionDuration = (New-TimeSpan -Days 3000)
#Set-ScheduledTask $nomeScript -Trigger $Gatilho

# O switch de IP 192.168.1.154 nao foi instalado na ETA cfe. projeto original.
$switches = @('152','153','155','156','157','158','159','160')
$comandos = @('admin', 'alianca164', 'show running-config', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ')
foreach ($switch in $switches)
{
    Write-host 'Verificando switch '$switch
    
    #Remove o arquivo existente para evitar erros de gravacao, ficando coisa antiga, etc.
    #$arqBkp = 'C:\DOCTOS\Informatica\infra\Config_rede\configuracao_switch_' + $switch + '.txt'
    $arqBkp = '\\192.168.1.12\Documentos\Informatica\infra\Config_rede\configuracao_switch_' + $switch + '.txt'
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
