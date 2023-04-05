# Descricao: Monitora servicos do Protheus.
#            Tivemos casos de travamento do servidor por que a aplicacao usou 20 Gb
#            Apesar de parametrizado para bloquear novas conexoes, o servico nao derruba (pelo
#            menos atualmente) as conexoes que estiverem usando cada vez mais memoria.
# Autor....: Robert Koch
# Data.....: 14/02/2022

# ---------------------------------------------------------------------------
# Agendar uma tarefa no Windows para rodar este script.
# Como trata-se de script que roda em loop, a sugestao eh agendar execucoes a
# cada 5 ou 10 minutos, com opcao de finalizar a tarefa quando estiver sendo
# executada ha algumas horas. Isso para evitar, por exemplo, que fique travada
# ou executando alguma coisa desatualizada.

# ---------------------------------------------------------------------------
# Historico de atualizacoes:
# 11/09/2022 - Robert - Passa a rodar em loop, buscando evitar chamadas recorrentes do PowerShell
#                     - Passa a importar (via 'DOT Source') funcoes compartilhadas no SRVADM.
#                     - Melhorado loop de espera pela finalizacao do servico.
# 14/09/2022 - Robert - Passa a enviar avisos para o NaWeb
#


# ---------------------------------------------------------------------------
# Importa arquivos de funcoes via 'dot source' para que as funcoes possam ser usadas aqui.
. '\\SRVADM\c$\util\Scripts\Function_VA_Log.ps1'
. '\\SRVADM\c$\util\Scripts\Function_VA_Aviso.ps1'

# ---------------------------------------------------------------------------
VA_Log -TipoLog 'info' -MsgLog 'Iniciando execucao'

# Processamento em loop por tempo indeterminado.
$contadorDeLoops = 1
do
{
    # Pego os processos com '_1' e '_2' no final do nome por que o servico das licencas tem '_0'. Assim, deixo-o de fora da lista.
    $processos = (Get-WmiObject Win32_Process | ? {$_.Name -like '*appserver_1*' -or $_.Name -like '*appserver_2*'})

    foreach ($processo in $processos)
    {
	   
        # Dicas de fomatacao em https://ss64.com/ps/syntax-f-operator.html
        # VA_Log -TipoLog 'info' -MsgLog ($processo.WorkingSetSize.ToString('000,000,000,000.00') + '  ' + $processo.Name)
	    VA_Log -TipoLog 'info' -MsgLog ("{0,6:n2}" -f ($processo.WorkingSetSize /1GB) + ' GB ' + $processo.Name)
	
	    # Se usar muita memoria, vai ser um candidato a ser 'derrubado'.
	    if ($processo.WorkingSetSize -gt 6GB)
	    {
            $MsgMemoria = ($processo.Name + ' usando muita memoria: ' + ($processo.WorkingSetSize / 1GB).ToString("#.##") + ' GB')
		    VA_Log -TipoLog 'aviso' -MsgLog $MsgMemoria
            VA_Aviso -Tipo 'aviso' -Titulo $MsgMemoria -Texto $MsgMemoria -Destinatarios 'robert.koch' -Origem '[PowerShell]Monitoramento_Protheus'
        }

	    # Se usar memoria acima do limite, vai ser 'derrubado'.
	    if ($processo.WorkingSetSize -gt 7000000000)
	    {

            # Obtem o nome do servico atraves do seu PID
            $servico = Get-CimInstance -class win32_service | Where-Object processid -eq $processo.Handle
        
            # Testa se conseguiu executar o ultimo comando
            if ($?)
            {
		        # Cria um job para finalizar o servico no Windows.
		        # Isso por que algumas vezes os servicos nao respondem e o prompt nao retorma mais.
                # dica em https://stackoverflow.com/questions/10075943/powershell-pass-variable-to-start-job
		        start-job -scriptblock {stop-service $using:servico.Name}

                # Aguarda algum tempo pelo job e força o encerramento do processo.
                $contador = 30
                do{
                    Start-sleep 1
                    $IDs = (Get-WmiObject Win32_Process | ? {$_.Name -like $processo.Name}).Handle
                    VA_Log -TipoLog 'aviso' -MsgLog ('Servico(s) ainda pendente(s) sera(ao) finalizados (kill) em ' + $contador + ' segundos')
                    if ($IDs.Length -eq 0)
                    {
                        VA_Log -TipoLog 'info' -MsgLog 'Nao encontrei mais processo(s) pendente(s). Parece que finalizou.'
                        break
                    }
                } while ($contador-- -gt 0)
                foreach ($ID in $IDs)
                {
                    VA_Log -TipoLog 'aviso' -MsgLog ('derrubando processo ' + $ID + ' com PSKill')
	    	        &C:\util\pstools\pskill.exe $processo.Handle
                    VA_Log -TipoLog 'info' -MsgLog 'Retornou do PSKill.'
                }

            }
            else
            {
                throw $error[0].Exception
            }
	    }
    }

    VA_Log -TipoLog 'info' -MsgLog ('Iteracao numero ' + $contadorDeLoops + ' finalizada. Aguardando nova execucao...')
    Start-Sleep (60)
    $contadorDeLoops ++
} while (1 -eq 1)

