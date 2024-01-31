# Scrit para reiniciar servicos Protheus durante a madrugada.
# Data: 12/02/2020
# Autor: Robert Koch
#
# Historico de atualizacoes:
# 13/03/2020 - Robert - Nao faz mais a parada do TSS, pois pode ser reiniciado durante o dia caso necessario.
# 06/04/2020 - Robert - Adicionados servicos LOJA e BROKER.
# 10/06/2020 - Robert - Adicionado servico TotvsSOA (mashups)
# 17/09/2020 - Robert - Readicionado servico TSS
# 05/03/2021 - Robert - Trocado comando pskill (o executavel sumiu da pasta) por 'Stop-Process' para derrubar processos pendentes.
# 11/03/2021 - Robert - Servico 'externo' incluido para ser parado e reiniciado.
# 18/08/2021 - Robert - Parada do servico do TSS nao estava agendada. Voltei a agendar.
# 15/10/2021 - Robert - Adicionados servicos WS, importador_XML e TAF
# 14/11/2021 - Robert - Adicionado servico retaguarda_PDV
# 19/09/2022 - Robert - Migrado para pasta compartilhada no SrvAdm
#                     - Passa a usar rotinas compartilhadas de log e aviso.
# 31/10/2023 - Robert - Acrescentado servico REST_MNTNG
#

# Importa arquivos de funcoes via 'dot source' para que as funcoes possam ser usadas aqui.
. '\\SRVADM\c$\util\Scripts\Function_VA_Log.ps1'
. '\\SRVADM\c$\util\Scripts\Function_VA_Aviso.ps1'

VA_Log -TipoLog 'info' -MsgLog 'Iniciando execucao'

# Cria um job para finalizar os servicos principais do Protheus.
# Isso por que algumas vezes os servicos nao respondem e o prompt nao retorma mais.
VA_Log -TipoLog 'info' -MsgLog 'Parando servicos...'
start-job {stop-Service 1*importador_XML*}  # O mais demorado para parar.
start-job {stop-Service 1*slave1*}
start-job {stop-Service 1*slave2*}
start-job {stop-Service 1*slave3*}
start-job {stop-Service 1*slave4*}
start-job {stop-Service 1*slave6*}
# O slave5 fica ativo por que eh usado para processos que demoram durante a noite, ex. custo medio.
start-job {stop-Service 1*master*}
start-job {stop-Service 1*broker*}
start-job {stop-Service 1*externo*}
start-job {stop-Service 1*loja*}
start-job {stop-Service 1*job_nf_cupom*}
start-job {stop-Service TotvsSOA*}
start-job {stop-Service 1*WS*}
start-job {stop-Service 1*TAF*}
start-job {stop-Service 1*REST_MNTNG*}

start-sleep 15

# O servico do TSS fica ativo um pouco mais, para atender casos do job de cupom que devem ser parados antes
start-job {stop-Service 1*TSS*}

# Aguarda algum tempo pelos jobs e força o encerramento dos processos.
$contador = 60
do{
    Start-sleep 1
    $IDs = (Get-WmiObject Win32_Process | ? {$_.Name -like '*appserver_slave1*' -or $_.Name -like '*appserver_slave2*' -or $_.Name -like '*appserver_slave3*' -or $_.Name -like '*appserver_slave4*' -or $_.Name -like '*appserver_slave6*' -or $_.Name -like '*appserver_loja*'  -or $_.Name -like '*appserver_externo*' -or $_.Name -like '*appserver_master*' -or $_.Name -like '*appserver_job_nf_cupom*' -or $_.Name -like '1*WS*' -or $_.Name -like '*importador_XML*' -or $_.Name -like '1*TAF*' -or $_.Name -like '1*REST_MNTNG*'}).Handle
    VA_Log -TipoLog 'info' -MsgLog ('Processo(s) ainda em execucao:' + $IDs)
    VA_Log -TipoLog 'info' -MsgLog ('Servico(s) ainda pendente(s) sera(ao) finalizados (kill) em ' + $contador + ' segundos')
    if ($IDs.Length -eq 0)
    {
        VA_Log -TipoLog 'info' -MsgLog 'Nao encontrei mais processo(s) pendente(s)'
        break
    }
} while ($contador-- -gt 0)
foreach ($ID in $IDs)
{
    VA_Log -TipoLog 'info' -MsgLog ('Derrubando (-force) processo ' + $ID)
    Stop-Process $ID -Force
}

start-sleep 10
start-service 1*TSS*
start-sleep 10

# Parece que as vezes ele simplesmente ta com preguica de iniciar...
start-service 1*TSS*
start-sleep 10

start-service 1*slave1*
start-service 1*slave2*
start-service 1*slave3*
start-service 1*slave4*
start-service 1*slave6*
start-service 1*master*
start-service 1*broker*
start-service 1*externo*
start-service 1*loja*
start-service 1*job_nf_cupom*
start-service TotvsSOA*
start-service 1*WS*
start-service 1*TAF*
start-service 1*REST_MNTNG*
start-service 1*importador_XML*

# Servico enjoado, parece que nao sobe na primeira chamada...
start-sleep 20
start-service 1*importador_XML*
start-sleep 60
start-service 1*importador_XML*
