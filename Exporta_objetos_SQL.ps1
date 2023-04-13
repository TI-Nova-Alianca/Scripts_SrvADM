# Descricao: Exporta alguns objetos do banco de dados (inicialmente procedures,
#            functions e views) para arquivo texto, para posteriormente termos
#            um versionamento via GIT.
# Royalties: https://x86x64.wordpress.com/2015/06/18/export-recently-modified-sql-stored-procedures-with-powershell/
# Autor....: Robert Koch
# Data.....: 19/12/2022

# ---------------------------------------------------------------------------
# Agendar uma tarefa no Windows para rodar este script.
# Como trata-se de script que roda em loop, a sugestao eh agendar execucoes a
# cada 1 hora ou mais, com opcao de finalizar a tarefa quando estiver sendo
# executada ha algumas horas. Isso para evitar, por exemplo, que fique travada
# ou executando alguma coisa desatualizada.

# ---------------------------------------------------------------------------
# Historico de atualizacoes:
# 30/12/2022 - Robert - Passa a gerar lista de objetos a exportar via query
#                       e nao mais pelas funcoes de integracao com SMO.
# 24/02/2023 - Robert - Filtrar objetos '%diagram%' (padrao do SQL)
#                     - Passa a rodar em loop.
# 05/04/2023 - Robert - Melhorado filtro objetos Protheus.
#

# ---------------------------------------------------------------------------
# Importa arquivos de funcoes via 'dot source' para que as funcoes possam ser usadas aqui.
. '\\SRVADM\c$\util\Scripts\Function_VA_Log.ps1'
. '\\SRVADM\c$\util\Scripts\Function_VA_Aviso.ps1'

# ---------------------------------------------------------------------------
VA_Log -TipoLog 'info' -MsgLog 'Iniciando execucao'
$Continua = 1

# Abre uma conexao com o database em questao para, posteriormente,
# verificar data da ultima modificacao do objeto.
# Nao consegui usar a propriedade DateLastModified (estava me retornando errado).
if ($Continua -eq 1)
{
    $SQLConnection = new-object System.Data.SqlClient.SQLConnection("Data Source=" + $env:ComputerName + ";Integrated Security=SSPI;Initial Catalog=" + $db.Name);
    $SQLConnection.Open();
    if ($SQLConnection.State -ne 'Open')
    {
        VA_Log -TipoLog 'erro' -MsgLog 'Erro de conexao ao SQL'
        VA_Aviso -Tipo 'erro'  -Titulo 'Erro conexao SQL ao exportar objetos' -Texto 'Erro de conexao ao SQL' -Destinatarios 'robert.koch' -Origem '[PowerShell]Bkp_objetos_SQL'
        $Continua = 0
    }
}

if ($Continua -eq 1)
{
    # Lets load the SMO assembly first (this is basically a collection of SQL Server related objects)
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") # | Out-Null
   
    # Lets initiate a SQL server object
    $srv = New-Object "Microsoft.SqlServer.Management.SMO.Server" $env:ComputerName

    # Cria pasta base para os backups
    $PastaBaseBackup = "c:\util\Bkp_Objetos_SQL"
    if (!(Test-Path -Path $PastaBaseBackup))
    {
	    New-Item -Force -ItemType Directory -Path $PastaBaseBackup
    }
}

# Processamento em loop por tempo indeterminado.
$contadorDeLoops = 1
do
{
    foreach ($db in $srv.Databases | where {$_.IsSystemObject -eq $false})
    {

        # Preciso estar com o database 'em uso' para listar os objetos.
        $SQLCmd = New-Object System.Data.SqlClient.SqlCommand(("use " + $db.Name), $SQLConnection)
        $SQLCmd.executenonquery() > $null

        # Como nao quero exportar para todos os databases, vou fazer um tratamento aqui.
        # Quem nao tiver pasta definida para backup nao vai ser exportado.
        switch ($db.Name)
        {
            "MercanetPRD"           {$PastaBackup = $PastaBaseBackup + "\Mercanet"}
            "MercanetPRD0708"       {$PastaBackup = ""}
            "BI_ALIANCA_testeMedio" {$PastaBackup = ""}
            "naweb_teste"           {$PastaBackup = ""}
            "protheus_testefiscal"  {$PastaBackup = ""}
            "protheus_teste"        {$PastaBackup = ""}
            "protheus"              {$PastaBackup = $PastaBaseBackup + "\Protheus"}
            "BL01"                  {$PastaBackup = $PastaBaseBackup + "\BL01"}
            "MercanetHML"           {$PastaBackup = $PastaBaseBackup + "\MercanetHML"}
            "naweb"                 {$PastaBackup = $PastaBaseBackup + "\NaWeb"}

#            default
#            {
#                $PastaBackup = $PastaBaseBackup + "\" + $db.Name
#            }
        }
        
        # Quem nao tiver pasta definida para backup nao vai ser exportado.
        if ($PastaBackup -ne "")
        {
            # Cria pasta para objetos do database atual.
            if (!(Test-Path -Path $PastaBackup))
            {
	            New-Item -Force -ItemType Directory -Path $PastaBackup
            }
            VA_Log -TipoLog 'info' -MsgLog ($DB.Name + ': Gerando lista de objetos')

            # Verifica data de criacao ou modificacao do objeto.
            # A propriedade DateLastModified (pelo PowerShell) estava me retornando errado.
            $SQLQuery =  " with c as ("
            $SQLQuery += " SELECT case o.type"
            $SQLQuery += " when 'P' then 'Procedure'"
            $SQLQuery += " when 'V' then 'View'"
            $SQLQuery += " when 'TR' then 'Trigger'"
            $SQLQuery += " when 'TF' then 'Function'"  #-- Table
            $SQLQuery += " when 'FN' then 'Function'"  #-- Scalar
            $SQLQuery += " when 'IF' then 'Function'"  #-- Inline
            $SQLQuery += " else '' end as tipo"
            $SQLQuery += " , rtrim (OBJECT_NAME(sm.object_id)) AS nome"
            $SQLQuery += " , sm.definition"
            $SQLQuery += " FROM sys.sql_modules AS sm"
            $SQLQuery += " JOIN sys.objects AS o ON sm.object_id = o.object_id"
            $SQLQuery += " where upper (OBJECT_NAME(sm.object_id)) not like '%_OLD%'"
            $SQLQuery += " and OBJECT_NAME(sm.object_id) not like '%_excluir'"
            $SQLQuery += " and OBJECT_NAME(sm.object_id) not in ('sp_upgraddiagrams','sp_sysdiagrams','sp_helpdiagrams','sp_helpdiagramdefinition','sp_creatediagram','sp_renamediagram','sp_alterdiagram','sp_dropdiagram','fn_diagramobjects')"
         #   $SQLQuery += " where (create_date >= dateadd (day, -1, getdate ()) or modify_date >= dateadd (day, -1, getdate ()))"

            # A Totvs cria procedures loucamente e nao apaga depois... optei por ficar testando
            # os nomes e filtrando aqui quando surgir alguma que nao me interessar.
            if ($db.Name.ToUpper() -like '*PROTHEUS*')
            {
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'A30EMBRA_01'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'AF050%_01'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'ATF%_01'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'CAL_SLD_TIT%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'CT1%_01'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'CT2%_01'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'CTB%_01'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'F410SCFT%_01'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'FIN00%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'LASTDAY%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'M280%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'M300%_01'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'M330%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'M902%CLR%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'M902%SCGN%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'MA280%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'MA330%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'MAT0%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'MNTNG%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'MRP001%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'MSCALCPER%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'MSEXIST%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'MSSOMA1%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'MSSTRZERO%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'SPGERASRZ%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'PCO001%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'SC%01'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'SC214140'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like 'TTAT_%'"  # Totvs comecou a gravar tambem funcions em 2023.
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like '%XFILIAL%'"
                $SQLQuery += " and upper (OBJECT_NAME(sm.object_id)) not like '%010_STAMP'"
            }

            $SQLQuery += " )"
            $SQLQuery += " select c.*"
            $SQLQuery += " , replace (c.definition, 'CREATE ' + upper (c.tipo), 'ALTER ' + upper (c.tipo)) as definicao"
            $SQLQuery += " from c"
            $SQLQuery += " order by tipo, nome"

            VA_Log -TipoLog 'debug' -MsgLog ($SQLQuery)
            $SQLCmd = new-object System.Data.SqlClient.SqlCommand($SQLQuery, $SQLConnection);
            $SQLReader = $SQLCmd.ExecuteReader()
            while ($SQLReader.Read()) 
            {
                # Define nome do arquivo para onde vai ser exportado.
                $NomeArq = $PastaBackup + "\" + $SQLReader.GetValue(0) + " " + $SQLReader.GetValue(1) + ".sql"
              #  VA_Log -TipoLog 'debug' -MsgLog ('Exportando para ' + $NomeArq)
                $SQLReader.GetValue(3) > $NomeArq
            }
            $SQLReader.Close()

        }
    }

    #exit # durante testes

    VA_Log -TipoLog 'info' -MsgLog ('Iteracao numero ' + $contadorDeLoops + ' finalizada. Aguardando nova execucao...')
    Start-Sleep (3 * 60 * 60) # a cada 3 horas estah mais que bom
    $contadorDeLoops ++
} while ($Continua -eq 1)
