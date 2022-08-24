# Grava log em arquivo.
# Autor: Robert Koch
# Historico de alteracoes:
# 04/04/2016 - Robert - Cria pasta para logs, caso nao exista.
# 11/10/2020 - Robert - Funcao desmembrada do fonte oiginal e passa a ter seu proprio arquivo fonte.
#

Function Grava-Log
{
    Param([string]$msgori)
    $PastaLogs = 'C:\temp\'

    # Dica para pegar o nome do script encontrada em https://stackoverflow.com/questions/817198/how-can-i-get-the-current-powershell-executing-file
    # Parece nao funcionar quando se executa direto do ISE.
    $ScriptInvocation = (Get-Variable MyInvocation -Scope Script).Value
    $ScriptName = $ScriptInvocation.MyCommand.Name
    $ScriptName = $ScriptName.Replace('.ps1', '')

    $ArqLog = $ScriptName+'_'+(Get-Date -Format yyyyMMdd)+".log"
    $DataHora = Get-Date -Format yyyyMMdd-HHmmss
    $stack = Get-PSCallStack
#    $msg = "[" + $DataHora + "][" + [Environment]::UserName + "][" + $stack[1].Location + "] " + $msg
    $msg = ''
    $msg += "[" + $DataHora + "]"
    $msg += "[" + [Environment]::UserName + "]"
   # $msg += "[" + $stack[1].Location + "] "
    $msg += $msgori
    write-host $msg
    if ((Test-Path variable:PastaLogs) -and (Test-Path variable:ArqLog))
    {
        if (!(Test-Path -Path $PastaLogs))
        {
        	New-Item -Force -ItemType Directory -Path $PastaLogs
        }
        $msg >> $PastaLogs$ArqLog
    }
    else
    {
        write-output $msg
    }
}
