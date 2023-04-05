# Cooperativa Agroindustrial Nova Alianca
# Descricao: Grava log em arquivo.
# Autor....: Robert Koch
# Data.....: 2016

# Historico de alteracoes:
# 04/04/2016 - Robert - Cria pasta para logs, caso nao exista.
# 11/10/2020 - Robert - Desmembrada do fonte oiginal; passa a ter seu proprio arquivo fonte.
# 25/03/2021 - Robert - Comando write-host alterado para write-output para que
#                       seja pego pelo redirecionamento de saida na chamada (operador >> )
# 11/09/2022 - Robert - Passa a ser uma funcao compartilhada no SRVADM (outras maquinas
#                       podem usa-la via 'dot source')
#                     - Se o arquivo ficar grande, renomeia-o e inicia um novo.
# 14/09/2022 - Robert - Criada validacao para parametros
#


<# Nao gostei por que grava o log no servidor remoto
# Cria uma sessao remota para poder importar modulos de outro servidor.
#$SessaoRemota = New-PSSession -ComputerName SRVADM
$VAUtil = Import-Module -Name c:\util\scripts\Compartilhados\VAUtil -PSSession $SessaoRemota -ascustomobject -force
$GravaLog("Iniciando execucao");
get-module
Get-Command Grav*
Remove-Module VAUtil
#>

<#Versao antiga, com a funcao de log no proprio servidor.
# Importa modulo especifico e cria objeto para gravacao de logs.
#$log = Import-Module C:\util\scripts\log.psm1 -ascustomobject -force
#$log.arq = 'c:\temp\Derruba_protheus_usando_muita_memoria_' + (Get-Date -Format "yyyyMMdd") + '.log'
#$log.Grava("Iniciando execucao");
#>


# ---------------------------------------------------------------------------
Function VA_Log
{
    # Dicas boas sobre parametros: https://stackoverflow.com/questions/4988226/how-do-i-pass-multiple-parameters-into-a-function-in-powershell
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [ValidatePattern('info|aviso|debug|erro')]
         [string] $TipoLog,
         [Parameter(Mandatory=$true, Position=1)]
         [string]$MsgLog
    )
    
    $PastaLogs = 'C:\temp\'

    # Dica para pegar o nome do script encontrada em https://stackoverflow.com/questions/817198/how-can-i-get-the-current-powershell-executing-file
    # Parece nao funcionar quando se executa direto do ISE.
    $ScriptInvocation = (Get-Variable MyInvocation -Scope Script).Value
    $ScriptName = $ScriptInvocation.MyCommand.Name
    $ScriptName = $ScriptName.Replace('.ps1', '')
    #$ArqLog = $ScriptName+'_'+(Get-Date -Format yyyyMMdd)+".log"
    $ArqLog = $ScriptName+".log"

#    $stack = Get-PSCallStack
#    $MsgLog = "[" + $DataHora + "][" + [Environment]::UserName + "][" + $stack[1].Location + "] " + $MsgLog
#    $MsgLog += "[" + [Environment]::UserName + "]"
   # $MsgLog += "[" + $stack[1].Location + "] "

    $DataHora = Get-Date -Format "yyyyMMdd HH:mm:ss"
    $MsgLog2 = ''
   	
	if ($TipoLog.ToUpper() -eq 'INFO')
	{
		$MsgLog2 += '[INFO ]'
	}
   	elseif ($TipoLog.ToUpper() -eq 'AVISO')
	{
		$MsgLog2 += '[AVISO]'
	}
   	elseif ($TipoLog.ToUpper() -eq 'ERRO')
	{
		$MsgLog2 += '[ERRO ]'
	}
   	elseif ($TipoLog.ToUpper() -eq 'debug')
	{
		$MsgLog2 += '[DEBUG]'
	}
	
    $MsgLog2 += "[" + $DataHora + "]"
    $MsgLog2 += $MsgLog
	write-host $MsgLog2

	# Cria pasta para arquivo de log, caso ainda nao exista.
	if ((Test-Path variable:PastaLogs) -and (Test-Path variable:ArqLog))
    {
        if (!(Test-Path -Path $PastaLogs))
        {
        	New-Item -Force -ItemType Directory -Path $PastaLogs
        }
        
		# Se o arquivo jah estiver grande, renomeia-o e inicia um novo.
		IF (Test-Path $PastaLogs$ArqLog)
		{
			#write-host 'passou no path'
			#write-host (Get-Item $PastaLogs$ArqLog).length
			If ((Get-Item $PastaLogs$ArqLog).length -gt 2MB)
			{
				write-host 'Criando novo arquivo de log'
				# Encontra o ultimo arquivo de log e soma 1 ao seu nome.
				$UltimoArqLog = gci $PastaLogs$ArqLog* | Sort-Object -Property Name -Descending | Select -First 1
				write-host 'Ultimo log: ' $UltimoArqLog
				$SeqUltimoLog = $UltimoArqLog.Extension
				write-host 'Seq. ultimo log: ' $SeqUltimoLog
				if ($SeqUltimoLog.ToUpper() -eq '.LOG')
				{
					write-host 'ainda no 1o.arquivo de log'
					$SeqProxLog = 1
				}
				else
				{
					$SeqProxLog = [int]$SeqUltimoLog.Substring(4,3) + 1
				}
				write-host 'seq.prox.log: ' $SeqProxLog
				$ArqLogNovo = $ArqLog + $SeqProxLog.ToString('000')
				rename-item $PastaLogs$ArqLog $PastaLogs$ArqLogNovo
			}
		}

		# Grava mensagem no final do arquivo de log.
		$MsgLog2 >> $PastaLogs$ArqLog
    }
    else
    {
        write-output $MsgLog2
    }
}
