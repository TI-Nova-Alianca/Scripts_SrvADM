# Verificar: https://www.kittell.net/code/powershell-ftp-upload-directory-sub-directories/
# Descricao: Exporta XML de notas fiscais para a E-Sales via FTP.
# Autor....: Robert Koch (royalties para Edouard Kombo, consultado em 16/08/2016 em http://stackoverflow.com/questions/1867385/upload-files-with-ftp-using-powershell)
# Data.....: 01/09/08/2016
#
# Historico de alteracoes:
# 27/04/2017 - Robert - Filtragem de transportadora alterada de "A4_VAEESAL='S'" para "A4_VAEESAL!='N'"
# 25/08/2017 - Robert - Gera tags com dados de redespacho.
# 20/11/2017 - Robert - Invertidos nomes de pastas do FTP (passa a enviar para recebe_embarcador e nao mais para envia_embarcador) a pedido do Sr. Paulo (desenvolvimento E-Sales).
# 12/03/2018 - Robert - Tags obsCont buscavam dados do F2_TRANSP e nao do F2_REDESP
#                     - Gera tag obsCont somente se a transportadora do F2_REDESP estiver habilitada para envio ao E_Sales.
#                     - A tag obsCont estava em um nível abaixo do infCpl. Alterado para ficar no mesmo nivel.
# 19/11/2018 - Robert - Nao gera mais OBSCONT (REDESPACHO) por que jah vai vir no XML original do Protheus.
# 19/09/2022 - Robert - Migrado para pasta compartilhada no SrvAdm
#                     - Passa a usar rotinas compartilhadas de log e aviso.
# 08/03/2023 - Robert - Criado tratamento para exportar mais de uma filial (01 e 16) - GLPI 13289
#

# Acesso FTP e-Sales:
# IP 200.203.125.131
# User: nova.alianca
# Password: 6252xb1H

# Importa arquivos de funcoes via 'dot source' para que as funcoes possam ser usadas aqui.
. '\\SRVADM\c$\util\Scripts\Function_VA_Log.ps1'
. '\\SRVADM\c$\util\Scripts\Function_VA_Aviso.ps1'

VA_Log -TipoLog 'info' -MsgLog 'Iniciando execucao'

$PastaArq = 'c:\siga\protheus12\protheus_data\ESales\envio\'
$filiais = "'01','16'";

# Busca notas a exportar.
$SQLQuery = " WITH C AS ("
$SQLQuery += " SELECT F2_DOC"
$SQLQuery +=       " ,F2_SERIE"
$SQLQuery +=       " ,SA4.A4_NREDUZ"
$SQLQuery +=       " ,CAST(CAST(XML_SIG AS VARBINARY(max)) AS VARCHAR(max)) AS XML_SIG"
$SQLQuery +=       " ,RTRIM(CAST(CAST((SELECT TOP 1 SPED054.XML_PROT"
$SQLQuery +=                           " FROM SPED054"
$SQLQuery +=                          " WHERE SPED054.ID_ENT     = SPED050.ID_ENT"
$SQLQuery +=                            " AND SPED054.NFE_ID     = SPED050.NFE_ID"
$SQLQuery +=                            " AND SPED054.NFE_PROT  != ''"
$SQLQuery +=                            " AND SPED054.CSTAT_SEFR = '100'"
$SQLQuery +=                          " ORDER BY SPED054.DTREC_SEFR DESC"
$SQLQuery +=                                  " ,SPED054.HRREC_SEFR DESC)"
$SQLQuery +=         " AS VARBINARY(MAX)) AS VARCHAR(MAX))) AS XML_PROT"
$SQLQuery +=       " ,(SELECT TOP 1 SPED000.CONTEUDO"
$SQLQuery +=           " FROM SPED000"
$SQLQuery +=          " WHERE SPED000.D_E_L_E_T_ = ''"
$SQLQuery +=            " AND SPED000.ID_ENT     = SPED050.ID_ENT"
$SQLQuery +=            " AND SPED000.PARAMETRO  = 'MV_VERSAO') AS MV_VERSAO"
$SQLQuery +=       " ,F2_FILIAL"
$SQLQuery += " FROM	SPED050"
$SQLQuery +=     " ,SA4010 SA4"
$SQLQuery +=     " ,SF2010 SF2"
$SQLQuery += " WHERE SF2.D_E_L_E_T_  = ''"
$SQLQuery +=   " AND SF2.F2_FILIAL  in (" + $filiais + ")"
$SQLQuery +=   " AND SF2.F2_EMISSAO >= CONVERT (VARCHAR (8), DATEADD (DAY, -30, GETDATE()), 112)"
$SQLQuery +=   " AND SF2.F2_VAEESAL != 'S'"  # Ainda nao exportadas
$SQLQuery +=   " AND SF2.F2_CHVNFE  != ''"
$SQLQuery +=   " AND SA4.D_E_L_E_T_  = ''"
$SQLQuery +=   " AND SA4.A4_FILIAL   = '  '"
$SQLQuery +=   " AND SA4.A4_COD      = SF2.F2_TRANSP"
$SQLQuery +=   " AND SA4.A4_VAEESAL  = 'S'" # Transp. marcada como 'tem integracao com E-Sales'
$SQLQuery +=   " AND SPED050.D_E_L_E_T_ = ''"
$SQLQuery +=   " AND SPED050.ID_ENT = (SELECT ID_ENT"
$SQLQuery +=                           " FROM SPED001"
$SQLQuery +=                               " ,SYS_COMPANY"
$SQLQuery +=                          " WHERE SPED001.D_E_L_E_T_     = ''"
$SQLQuery +=                            " AND SYS_COMPANY.D_E_L_E_T_ = ''"
$SQLQuery +=                            " AND SYS_COMPANY.M0_CODIGO  = '01'"
$SQLQuery +=                            " AND SYS_COMPANY.M0_CODFIL  = SF2.F2_FILIAL"
$SQLQuery +=                            " AND SPED001.CNPJ           = SYS_COMPANY.M0_CGC"
$SQLQuery +=                            " AND SPED001.IE             = SYS_COMPANY.M0_INSC)"
$SQLQuery +=   " AND SPED050.NFE_ID = SF2.F2_SERIE + SF2.F2_DOC"
$SQLQuery += ")"
$SQLQuery += "SELECT F2_DOC"
$SQLQuery +=      " ,F2_SERIE"
$SQLQuery +=      " ,A4_NREDUZ"
$SQLQuery +=      " ,SUBSTRING (XML_SIG, 1, len (XML_SIG) - 1) AS XML_SIG"  # Acoxambramento para remover o caracter NUL do final da string. Parece ser por causa do MAX nos tamanhos do CAST. Vai saber...
$SQLQuery +=      " ,SUBSTRING (XML_PROT, 1, len (XML_PROT) - 1) AS XML_PROT"  # Acoxambramento para remover o caracter NUL do final da string. Parece ser por causa do MAX nos tamanhos do CAST. Vai saber...
$SQLQuery +=      " ,MV_VERSAO"
$SQLQuery +=      " ,F2_FILIAL"
$SQLQuery +=  " FROM C"
$SQLQuery += " ORDER BY F2_FILIAL"
$SQLQuery +=      " ,F2_DOC"
VA_Log -TipoLog 'info' -MsgLog $SQLQuery

$SQLConnection = new-object System.Data.SqlClient.SQLConnection("Data Source=192.168.1.4;Integrated Security=SSPI;Initial Catalog=protheus");
$SQLCmd = new-object System.Data.SqlClient.SqlCommand($SQLQuery, $SQLConnection);
$SqlCmd.CommandTimeout = 120;
$SQLConnection.Open();
$SQLReader = $SQLCmd.ExecuteReader()

# Monta array com os dados retornados, para poder fechar a query, senao nao consigo gerar UPDATE posteriormente.
$Registros = [System.Collections.ArrayList]@()
while ($SQLReader.Read()) {
    $reg = @($SQLReader.GetValue(0), $SQLReader.GetValue(1), $SQLReader.GetValue(2), $SQLReader.GetValue(3), $SQLReader.GetValue(4), $SQLReader.GetValue(5), $SQLReader.GetValue(6))
    $Registros.Add($reg) #> $null
}
$SQLReader.Close()
if ($Registros.Count -eq 0) {
    VA_Log -TipoLog 'info' -MsgLog "Nenhum registro retornado do SQL"
}


$Contador = 0
foreach ($reg in $Registros)
{
    Write-progress -Activity 'Exportando NF '$reg[0] -PercentComplete  ((++$Contador * 100) / $Registros.Count)
    VA_Log -TipoLog 'info' -MsgLog ('Processando NF '+$reg[0])

    $doc      = $reg[0].Trim()
    $serie    = $reg[1].Trim()
    $nreduz   = $reg[2].Trim().Replace(' ', '').Replace('.', '').Replace('-', '').Replace('/', '')
    $xml_sig  = $reg[3].ToString()
    $xml_prot = $reg[4].Trim()
    $versao   = $reg[5].Trim()
    $filialNF = $reg[6].Trim()
    $xml_sig2 = $xml_sig

    # Monta os dados para o XML
    $str = ''
    $str += '<?xml version="1.0" encoding="UTF-8"?>'
    $str += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + $versao + '">'
    $str += $xml_sig2
    $str += $xml_prot
    $str += '</nfeProc>'

    # Converte para XML para ter certeza do conteudo (poderia exportar direto para o arquivo).
    $xml = New-Object -TypeName System.Xml.XmlDocument
    try {
        $xml.LoadXml($str)

        # Exporta para arquivo.
        $arqDest = $PastaArq + 'Filial_' + $filialNF + '_NF_' + $doc + '_' + $nreduz + '.xml'
        VA_Log -TipoLog 'info' -MsgLog ('Gerando arquivo '+$arqDest)
        $stream = [System.IO.StreamWriter] ($arqDest)
        $stream.Write($str)
        $stream.close()

        # Marca a nota como jah exportada.
        $SQLUpd = "UPDATE SF2010"
        $SQLUpd += " SET F2_VAEESAL = 'S'"
        $SQLUpd += " WHERE D_E_L_E_T_ = ''"
        $SQLUpd +=   " AND F2_FILIAL  = '" + $filialNF + "'"
        $SQLUpd +=   " AND F2_DOC     = '" + $doc + "'"
        $SQLUpd +=   " AND F2_SERIE   = '" + $serie + "'"
        VA_Log -TipoLog 'info' -MsgLog ($SQLUpd)
        $SQLCmd = New-Object System.Data.SqlClient.SqlCommand($SQLUpd, $SQLConnection)
        if ($SQLCmd.executenonquery() -ne 1)
        {
            VA_Log -TipoLog 'erro' -MsgLog ('Erro na execucao do comando SQL: ' + $SQLUpd)
        }
    }
    catch
    {
        # Discovering the full type name of an exception
        VA_Log -TipoLog 'erro' -MsgLog ($_.Exception.gettype().fullName)
        VA_Log -TipoLog 'erro' -MsgLog ($_.Exception.message)
    }
}


# Envia arquivos por FTP
VA_Log -TipoLog 'info' -MsgLog 'Verificando se ha arquivos para enviar por FTP'

#ftp server params
$ftp = 'ftp://200.9.174.224/'
$user = 'nova.alianca'
$pass = '6252xb1H'

#Connect to ftp webclient
$webclient = New-Object System.Net.WebClient 
$webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass)  

#Search for files in directory
foreach($item in (dir $PastaArq "*.xml"))
{

    #Get file creation dateTime...
    $fileDateTime = (Get-ChildItem $item.fullName).CreationTime

    #Convert dateTime to timeStamp
    $fileTimeStamp = (Get-Date $fileDateTime).ToFileTime()

    #Get actual timeStamp
    $timeStamp = (Get-Date).ToFileTime() 

    #Get file lifeTime
    $fileLifeTime = $timeStamp - $fileTimeStamp

    #We only treat files that are fully written on the disk
    #So, we put a 2 second delay to ensure even big files have been fully wirtten in the disk
    if($fileLifeTime -gt "2") {    

        $arqOrigFTP = $item.FullName
        $arqDestFTP = $ftp+'recebe_embarcador/'+$item.Name
        VA_Log -TipoLog 'info' -MsgLog ('FTP -> ' + $arqOrigFTP + ' --> ' + $arqDestFTP)

        try{
            $uri = New-Object System.Uri($arqDestFTP)
            $webclient.UploadFile($uri, $arqOrigFTP)
            sleep (0.2) # Aguarda ate ser finalizada a transmissao.

            # Guarda uma copia do arquivo (usar apenas durante fase de testes)
            Copy-Item $item.fullName 'c:\siga\protheus12\protheus_data\ESales\envio\copia_dos_XML_enviados\'

            Remove-Item $item.fullName
        } catch [Exception] {
            write-host $_.Exception.Message;
        }
    }
}

# Estamos com o Zabbix fora do ar ----> & C:\Util\Scripts\Envia_para_Zabbix.ps1 ESales_erros_FTP 0 'SERVERPROTHEUS';
VA_Log -TipoLog 'info' -MsgLog "Finalizando execucao"
