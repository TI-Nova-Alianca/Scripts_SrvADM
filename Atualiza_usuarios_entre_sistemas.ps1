# Descricao: Script para atualizar dados de usuarios entre diferentes sistemas.
#            Exportar usuarios do A.D. para o SQL, bloqueia pessoas de ferias, etc.
# Autor....: Robert Koch
# Data.....: 10/12/2020

# ---------------------------------------------------------------------------
# Agendar uma tarefa no Windows para rodar este script.
# Como trata-se de script que roda em loop, a sugestao eh agendar execucoes a
# cada 1 hora, com opcao de finalizar a tarefa quando estiver sendo
# executada ha algumas horas. Isso para evitar, por exemplo, que fique travada
# ou executando alguma coisa desatualizada.

# ---------------------------------------------------------------------------
# Historico de alteracoes:
# 18/10/2022 - Robert - Criada versao que roda em loop (ganho de performance com
#                       a carga do modulo A.D. apenas uma vez)
#                     - Passa a usar funcoes externas de log e envio de avisos.
#                     - Melhorada estrutura (verifica se deu erro no SQL, etc.)
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

    # Atualiza, no SQL, a tabela de usuarios do A.D.
    $SQLUser = "consultas"
    $pwdSQL = "consultas" | ConvertTo-SecureString -AsPlainText -Force
    $pwdSQL.MakeReadOnly()
    $credSQL = New-Object System.Data.SqlClient.SqlCredential($SQLUser,$pwdSQL)
    $connectionSQL = new-object System.Data.SqlClient.SQLConnection("Data Source=ServerSQL;Initial Catalog=TI");
    $connectionSQL.credential = $credSQL
    $connectionSQL.Open();
    if ($connectionSQL.State -ne 'Open')
    {
        VA_Log -TipoLog 'erro' -MsgLog "Erro de conexao ao banco de dados"
        VA_Aviso -Tipo 'erro' -Titulo "Erro na atualizacao de usuarios" -Texto "Erro na atualizacao de usuarios. Verifique log" -Destinatarios 'robert.koch;fabiano.fernandes' -Origem '[PowerShell]Atualiza_usuarios_entre_sistemas'
    }
    else
    {
        # Limpa tabela para depois popular novamente, assim tenho certeza que usuarios apagados do AD nao ficaram no SQL
        $querySQL  = "delete USUARIOS_AD"
        VA_Log -TipoLog 'info' -MsgLog $querySQL
        $cmdSQL = new-object System.Data.SqlClient.SqlCommand($querySQL, $connectionSQL);
        $resultExecSQL = $cmdSQL.ExecuteNonQuery()
        VA_Log -TipoLog 'info' -MsgLog ('Apagados ' + $resultExecSQL + ' registros da tabela de usuarios do A.D. no SQL')
        if ($resultExecSQL -eq -1)
        {
            VA_Log -TipoLog 'erro' -MsgLog "Erro ao limpar a tabela de usuarios do AD no SQL"
            VA_Aviso -Tipo 'erro' -Titulo "Erro na atualizacao de usuarios" -Texto "Erro na atualizacao de usuarios. Verifique log" -Destinatarios 'robert.koch;fabiano.fernandes' -Origem '[PowerShell]Atualiza_usuarios_entre_sistemas'
        }
        else
        {
	        $usersAD = @(get-aduser -Filter * -Properties name, employeeID)
            VA_Log -TipoLog 'info' -MsgLog ('Encontrados ' + $usersAD.Count + ' usuarios no A.D.')
            $usersInseridosNoSQL = 0
	        foreach ($userAD in $usersAD)
	        {
		        $querySQL  = "insert into USUARIOS_AD ("
		        $querySQL += "SamAccountName, Enabled, EmployeeID"
		        $querySQL += ") values ("
		        $querySQL += "'" + $userAD.SamAccountName + "'"
		        if ($userAD.Enabled)
		        {
			        $querySQL += ",'S'"
		        }
		        else
		        {
			        $querySQL += ",'N'"
		        }
		        $querySQL += ",'" + $userAD.EmployeeID + "'"
		        $querySQL += ")"
		        #VA_Log -TipoLog 'info' -MsgLog $querySQL
		        $cmdSQL = new-object System.Data.SqlClient.SqlCommand($querySQL, $connectionSQL);
		        $resultExecSQL = $cmdSQL.ExecuteNonQuery()
                if ($resultExecSQL -ne 1)
                {
                    VA_Log -TipoLog 'erro' -MsgLog "Erro ao inserir registro na tabela de usuarios do AD no SQL"
                    VA_Aviso -Tipo 'erro' -Titulo "Erro na atualizacao de usuarios" -Texto "Erro na atualizacao de usuarios. Verifique log" -Destinatarios 'robert.koch;fabiano.fernandes' -Origem '[PowerShell]Atualiza_usuarios_entre_sistemas'
                    exit
                }
                else
                {
                    $usersInseridosNoSQL ++
                }
	        }
            VA_Log -TipoLog 'info' -MsgLog ('Inseridos no SQL ' + $usersInseridosNoSQL + ' usuarios do A.D.')
        }
    }

    VA_Log -TipoLog 'info' -MsgLog ('Iteracao numero ' + $contadorDeLoops + ' finalizada. Aguardando nova execucao...')
    Start-Sleep (1800)
    $contadorDeLoops ++
} while (1 -eq 1)