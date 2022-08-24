# Script de coleta e envio de dados para o servidor Zabbix (monitoramento) - Vinicola Nova Alianca
#
# COMO ENCONTRA-SE NO SRV_ADM, PRECISA SER CHAMADO VIA COMANDO INVOKE, A PARTIR DE OUTRO SCRIPT.
#
# Autor: Robert Koch
# Data: 15/10/2015
#
# Historico de alteracoes:
# 23/09/2018 - Robert - SQL trocou de servidor
# 18/11/2018 - Robert - Migrado do SQLServer para SrvADM e passa a ser executado remotamente.
# 30/04/2019 - Robert - Passa a enviar contagem de registros da tabela TSS0004
# 06/05/2019 - Robert - Passa a enviar quantidade de registros do ZZX sem revalidacao de chave.
# 19/08/2019 - Robert - Nao desconsiderava o status '5' na leitura de etiquenas pendentes Full.
# 16/10/2019 - Robert - Passa a monitorar percentual de uso do arquivo de log do database do Protheus.
# 01/11/2019 - Robert - Passadas algumas verificacoes do ServerProtheus para ca.
# 19/11/2019 - Robert - Incluida contagem de batches atrasados
# 05/05/2021 - Robert - Contagem de batches atrasados passa a usar a view TI.dbo.MONITOR_BATCHES_PROTHEUS
# 29/08/2021 - Robert - Verificacoes feitas em SQL migradas para Zabbix novo (roda via agente direto no ServerProtheus)
#

<# Migrados para Zabbix novo
# Usa credencial de 'consultas' para conectar ao SQL
$SQLUser = "consultas"
$Password = "consultas" | ConvertTo-SecureString -AsPlainText -Force
$Password.MakeReadOnly()
$cred = New-Object System.Data.SqlClient.SqlCredential($SQLUser,$Password)
$connection = new-object System.Data.SqlClient.SQLConnection("Data Source=serverSQL;Initial Catalog=protheus");
$connection.credential = $cred
$connection.Open();


$verificacoesSQL = @{
#    batches_protheus_iniciados             = "select count (*) from TI.dbo.MONITOR_BATCHES_PROTHEUS where ATIVO = 'S' and EXECUTOU_OK like 'I%' and EXECUTANDO_MINUTOS >= 30"
#    batches_protheus_abortados             = "SELECT COUNT (*) FROM ZZ6010 WHERE D_E_L_E_T_ = '' AND ZZ6_RODADO = 'K' AND DATEDIFF (HOUR, cast(ZZ6_DTUEXE + ' ' + ZZ6_HRUEXE + ':00' AS DATETIME), GETDATE ()) >= 1"  # Iniciado ha mais de 1 hora
#    protheus_minutos_execucao_ultimo_batch = "SELECT DATEDIFF (MINUTE, MAX (ZZ6_DTUEXE + ' ' + ZZ6_HRUEXE), CURRENT_TIMESTAMP) FROM ZZ6010 WHERE D_E_L_E_T_ = ''"
#    emissao_doc_contingencia               = "SELECT COUNT (*) FROM SPED000 WHERE PARAMETRO = 'MV_MODALID' AND CONTEUDO != '1' AND ID_ENT IN (SELECT ID_ENT FROM SPED001, VA_SM0 WHERE CNPJ = M0_CGC AND IE = M0_INSC AND VA_SM0.D_E_L_E_T_ = '')"
#    etiq_sem_guarda_FullWMS                = "select count (*) from tb_wms_entrada where status = '3' and status_protheus not in ('3', 'C', '5') and datediff (HOUR, dthr, GETDATE ()) >= 1"
#    qt_registros_TSS0004                   = "select count (*) from TSS0004 WHERE D_E_L_E_T_ = ''"
#    qt_XML_sem_valid_chave                 = "SELECT COUNT (*) FROM ZZX010 ZZX WHERE D_E_L_E_T_ = '' AND ZZX.ZZX_DUCC < ZZX.ZZX_EMISSA AND DATEDIFF (DAY, CAST (ZZX_DTIMP + ' ' + '00:00' AS DATETIME), GETDATE ()) <= 90"
#    XML_nao_enviado_WS_Walmart             = "SELECT COUNT (*) FROM SF2010 SF2, SA1010 SA1 WHERE SF2.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '  ' AND SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA AND SF2.F2_TIPO NOT IN ('D', 'B') AND SA1.A1_VAEDING = '3' AND SF2.F2_EMISSAO >= CONVERT (VARCHAR (8), DATEADD (DAY, -60, GETDATE()), 112) AND SF2.F2_VAENVWS != 'S'"
    #qt_registros_VA_USR_USUARIOS           = "SELECT COUNT (*) FROM VA_USR_USUARIOS"

    # Formula: max_size eh guardado em qt.de paginas de 8Kb
#	SQL_percent_tamanho_arq_log_protheus   = "select total_log_size_in_bytes/1024 * 100 / (select max_size*8*1.0 from sys.database_files where type = 1) AS PERCENT_TAMANHO_LOG_EM_RELACAO_AO_TAM_MAX from protheus.sys.dm_db_log_space_usage"

#	protheus_batches_atrasados             = "SELECT count (*) FROM ZZ6010 WHERE D_E_L_E_T_ = '' AND ZZ6_ATIVO = 'S' AND dbo.VA_FPROX_EXEC_BATCH (R_E_C_N_O_, ZZ6_EMPDES, ZZ6_FILDES) < DATEADD (MINUTE, -10, CURRENT_TIMESTAMP)"
#	protheus_batches_atrasados             = "SELECT count (*) FROM TI.dbo.MONITOR_BATCHES_PROTHEUS WHERE MINUTOS_ATRASO > 10"
}
foreach ($h in $verificacoesSQL.Keys) {
    $query = $($verificacoesSQL.Item($h))
    $cmd = new-object System.Data.SqlClient.SqlCommand($query, $connection);
    $reader = $cmd.ExecuteReader()
    if ($reader.Read())
    {
        #Write-Host ${h}: $reader.GetValue(0)
        & C:\Util\Scripts\Envia_para_Zabbix.ps1 ${h} $reader.GetValue(0) $env:COMPUTERNAME
    }
    $reader.Close()
}
#>

#Envia quantidade de arquivos de EDI parados
#migrado para Zabbix novo $qt_arq_edi_ped = (get-childitem c:\siga\protheus12\protheus_data\mercador\ped\*.* | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddMinutes(-30)} | Measure-Object).count
#migrado para Zabbix novo $qt_arq_edi_nf = (get-childitem c:\siga\protheus12\protheus_data\mercador\nf\*.txt | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddMinutes(-30)} | Measure-Object).count
#migrado para Zabbix novo & C:\Util\Scripts\Envia_para_Zabbix.ps1 arq_edi_ped_a_importar $qt_arq_edi_ped $env:COMPUTERNAME
#migrado para Zabbix novo & C:\Util\Scripts\Envia_para_Zabbix.ps1 arq_edi_nf_a_exportar $qt_arq_edi_nf $env:COMPUTERNAME


# Verifica ha quantas horas rodou a ultima execucao do client
#migrado para Zabbix novo $ArqLogNeogrid = 'C:\NeoGridClient\logs\neogrid.log'
#migrado para Zabbix novo $HorasUltExecWebEDI = ([System.DateTime]::Now - (gci $ArqLogNeogrid).LastWriteTime).Hours
#migrado para Zabbix novo & C:\Util\Scripts\Envia_para_Zabbix.ps1 horas_ult_exec_webedi $HorasUltExecWebEDI $env:COMPUTERNAME


#migrado para Zabbix novo # Procura linhas de erro nas ultimas linhas do arquivo de log do EDI da Neogrid.
#migrado para Zabbix novo $ErrosLogNeogrid = @(Get-Content $ArqLogNeogrid | Select-Object -last 1000 | Select-String -Pattern 'FATAL').Count
#migrado para Zabbix novo & C:\Util\Scripts\Envia_para_Zabbix.ps1 erros_log_webedi $ErrosLogNeogrid $env:COMPUTERNAME


#Envia quantidade de arquivos XML a importar
$qt_arq_xml_nfe = (get-childitem c:\siga\protheus12\protheus_data\xml_nfe\*.xml | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddMinutes(-30)} | Measure-Object).count
$qt_arq_xml_cte = (get-childitem c:\siga\protheus12\protheus_data\xml_nfe\CT-e\*.xml | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddMinutes(-30)} | Measure-Object).count
& c:\util\scripts\Envia_para_Zabbix.ps1 arq_XML_NFe_a_importar $qt_arq_xml_nfe $env:COMPUTERNAME
& c:\util\scripts\Envia_para_Zabbix.ps1 arq_XML_CTe_a_importar $qt_arq_xml_cte $env:COMPUTERNAME


# Verifica se existem e-mails com erro e pendentes de envio.
# Dica para contagem de arquivos encontrada em http://stackoverflow.com/questions/14714284/count-items-in-a-folder-with-powershell
# Well, it turns out that this is a quirk caused precisely because there was only one file in the directory. Some searching revealed that in this case, PowerShell returns a scalar object instead of an array. This object doesn’t have a count property, so there isn’t anything to retrieve.
# The solution -- force PowerShell to return an array with the @ symbol:
#
#migrado para Zabbix novo $Emails_pendentes_envio_protheus = @(Get-ChildItem c:\siga\Protheus12\protheus_data\workflow\emp??\mail\*\outbox\*.wfm | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddMinutes(-30)}).Count
#migrado para Zabbix novo & C:\Util\Scripts\Envia_para_Zabbix.ps1 emails_pendentes_envio_protheus $Emails_pendentes_envio_protheus $env:COMPUTERNAME
#
#migrado para Zabbix novo $Emails_erro_envio_protheus = @(Get-ChildItem c:\siga\Protheus12\protheus_data\workflow\emp??\mail\*\outbox\error\*\*.wfm | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddMinutes(-30)}).Count
#migrado para Zabbix novo & C:\Util\Scripts\Envia_para_Zabbix.ps1 emails_com_erro_envio_protheus $Emails_erro_envio_protheus $env:COMPUTERNAME


<# Migrado para Zabbix novo
# Verifica se tem e-mails de EDI de fretes para baixar.
#Dica extraida de https://www.cogmotive.com/blog/powershell-scripts/pop-mailbox-using-powershell
$e_mails_a_baixar_edifrete = 0
$socket = new-object System.Net.Sockets.TcpClient('srvmail.novaalianca.coop.br', 7110)
$stream = $socket.GetStream() 
$writer = new-object System.IO.StreamWriter($stream) 
$buffer = new-object System.Byte[] 1024 
$encoding = new-object System.Text.AsciiEncoding 
start-sleep 1
$resposta = ''
while($stream.DataAvailable){  
	$read = $stream.Read($buffer, 0, 1024)    
	$resposta += ($encoding.GetString($buffer, 0, $read))  
}
write-host $resposta
if ($resposta.ToString().Substring(0, 3) -eq '+OK'){
    $writer.WriteLine("USER fretesimport") 
    $writer.Flush()
    start-sleep 1
    $resposta = ''
    while($stream.DataAvailable){  
	    $read = $stream.Read($buffer, 0, 1024)    
	    $resposta += ($encoding.GetString($buffer, 0, $read))  
    }
    write-host $resposta
    if ($resposta.ToString().Substring(0, 3) -eq '+OK'){
        $writer.WriteLine("PASS Alianca14")
        $writer.Flush()
        start-sleep 1
        $resposta = ''
        while($stream.DataAvailable){  
	        $read = $stream.Read($buffer, 0, 1024)    
	        $resposta += ($encoding.GetString($buffer, 0, $read))  
        }
        write-host $resposta
        if ($resposta.ToString().Substring(0, 3) -eq '+OK'){
            $writer.WriteLine("STAT")
            $writer.Flush()
            start-sleep 1
            $resposta = ''
            while($stream.DataAvailable){  
	            $read = $stream.Read($buffer, 0, 1024)    
	            $resposta += ($encoding.GetString($buffer, 0, $read))  
            }
            write-host $resposta
            & c:\util\scripts\Envia_para_Zabbix.ps1 e_mails_a_baixar_fretesimport $resposta.split(" ")[1] $env:COMPUTERNAME
            if ($resposta.ToString().Substring(0, 3) -eq '+OK'){
                $writer.WriteLine("QUIT")
                $writer.Flush()
                start-sleep 1
                $resposta = ''
                while($stream.DataAvailable){  
	                $read = $stream.Read($buffer, 0, 1024)    
	                $resposta += ($encoding.GetString($buffer, 0, $read))  
                }
                write-host $resposta
                if ($resposta.ToString().Substring(0, 3) -eq '+OK'){
                }else{
                    write-host 'Resposta do comando QUIT nao ok'
                }
            }else{
                write-host 'Resposta do comando STAT nao ok'
            }
        }else{
            write-host 'Resposta do comando PASS nao ok'
        }
    }else{
        write-host 'Resposta do comando USER nao ok'
    }
}
else{
    write-host 'Resposta inicial nao OK'
}
# Close the streams 	
$writer.Close() 
$stream.Close() 
#>

