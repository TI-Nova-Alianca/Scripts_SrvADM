# Script de manutencao do ServerProtheus a ser executado uma vez por noite.
# Este script é disparado, inicialmente, pelo agendador de tarefas do Windows.
# Autor: Robert Koch
# Data: 2013
#
# Historico de alteracoes:
# 08/06/2013 - Robert  - Incluido tratamento para limpeza de arquivos temporarios do Protheus.
# 08/05/2015 - Robert  - Limpeza de backups do arquivo de senhas, treport e workflows Protheus.
# 12/11/2015 - Robert  - Passa a fazer uma copia do SIGAADV para depois compactar.
# 03/05/2016 - Robert  - Passa a usar funcao grava-log
#                      - Passa a compactar e apagar arquivo de log do WebEDIMercador.
# 30/07/2016 - Robert  - Revisado para versao Protheus 12.
# 03/02/2017 - Robert  - Alterado caminho dos backups de g: para c:
# 25/07/2017 - Robert  - Filtro de logs de customizacoes mudado de 'u_*.log' para '*_*.log' na limpeza da pasta do Protheus.
# 29/08/2017 - Robert  - Acrescentada limpeza dos arquivos SC*.JOB
# 20/06/2018 - Robert  - Acrescentada limpeza da pasta Autocom
# 07/05/2019 - Robert  - Nao compacta mais os arquivos de log de console dos servicos do Protheus (nao ha necessidade).
# 31/10/2019 - Robert  - Eliminar pastas temporarias (*.idx) da pasta sigaadv
#                      - Melhoria filtros arquivos de log customizados para limpeza.
# 07/11/2019 - Robert  - Limpa RPOs de compilacoes antigas.
# 16/01/2020 - Robert  - Limpeza logs customizados Protheus
# 27/02/2020 - Robert  - Limpa arquivos mj*.job e sc*.job do Protheus que tiverem tamanho zero.
# 22/06/2020 - Robert  - Limpa nova pasta de logs do Protheus (protheus_data\Logs)
# 08/02/2021 - Fabiano - Linhas 74/75 incluso duas variaveis; Linhas 88/89 Comando para limpar as pastas Private e Public do NAWEB.
# 22/03/2021 - Robert  - Linhas de limpeza das pastas do NaWeb passadas mais para o inicio do script (parecia nao estar executando)
# 04/04/2021 - Robert  - Backup fontes Protheus desabilitado (agora temos no GitHub)
# 02/06/2022 - Robert  - Move arquivos de XML mais antigos para pasta onde nao sejam mais reprocessados pelo ImportadorXML da Totvs RS.
# 15/09/2022 - Robert  - Migrado para o SrvAdm (o agendamento do ServerProtheus vai buscar o script na rede)
#                      - Melhoria funcoes externas de geracao de logs e avisos.
#                      - Revisao geral de quais pastas devem ser verificadas.
# 10/11/2022 - Robert  - Limpeza arq.XML do importador TRS desabilitada (movia arquivos antes que fossem processados).
#

# Importa arquivos de funcoes via 'dot source' para que as funcoes possam ser usadas aqui.
. '\\SRVADM\c$\util\Scripts\Function_VA_Log.ps1'
. '\\SRVADM\c$\util\Scripts\Function_VA_Aviso.ps1'

VA_Log -TipoLog 'info' -MsgLog 'Iniciando execucao'


$DataHora = Get-Date -Format yyyyMMdd-HHmmss
$PastaBackups = "c:\Backups"
$PastaBaseProtheus   = "c:\siga\protheus12\protheus_data"
#$PastaFontesProtheus = "c:\siga\protheus12\protheus_data\Fontes"
$PastaSystemProtheus = "c:\siga\protheus12\protheus_data\Sigaadv"
$PastaLogsCustomizadosProtheus   = "c:\siga\protheus12\protheus_data\Logs"
$PastaCopiaSystemProtheus = "c:\backups\Copia_Sigaadv"
$PastaLimpezaSystemProtheus = "c:\siga\protheus12\protheus_data\backups\Limpeza_sigaadv"
$PastaAutocomProtheus = "c:\siga\protheus12\protheus_data\autocom"
$PastaSSRS = "c:\SSRS"
$Compactador = "C:\Util\Scripts\7za.exe"

# Cria pastas necessarias para backups, transferencias de arquivos, etc.
if (!(Test-Path -Path $PastaBackups))
{
	New-Item -Force -ItemType Directory -Path $PastaBackups
}
if (!(Test-Path -Path $PastaLimpezaSystemProtheus))
{
	New-Item -Force -ItemType Directory -Path $PastaLimpezaSystemProtheus
}


# mover pqara o servidor correto
#Grava-Log('Vou limpar pastas temporarias do NaWeb')
#$NawebPublicTempStorage = "C:\GeneXus\Models\NAWeb\CSharpModel\web\PublicTempStorage\"
#$NawebPrivateTempStorage = "C:\GeneXus\Models\NAWeb\CSharpModel\web\PrivateTempStorage\"
#Get-ChildItem $NawebPublicTempStorage  | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-1)} | remove-item -recurse -force
#Get-ChildItem $NawebPrivateTempStorage | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-1)} | remove-item -recurse -force


# Limpa arquivos temporarios, logs, etc. do sistema Protheus.
VA_Log -TipoLog 'info' -MsgLog 'Limpando arquivos temporarios e logs do Protheus'
Get-ChildItem $PastaSystemProtheus\sc??????.log | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\sc??????.mem | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\sc??????.idx | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\k_sc???????.ind | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\k_sc???????.idx | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\sc??????.cdx | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\sc??????.txt | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\sc??????     | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
foreach ($lg in (Get-ChildItem $PastaSystemProtheus\*.log | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-4)}))
{
    if ($lg | Select-String -pattern "Arquivo de log gerado por customizacoes Protheus")
    {
        Move-Item $lg.FullName -Destination $PastaLimpezaSystemProtheus
    }
}

Get-ChildItem $PastaLogsCustomizadosProtheus\*.log* | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-7)} | remove-item -Force

Get-ChildItem $PastaSystemProtheus\sc*.job | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-1) -or $_.Length -eq 0} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\mj*.job | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-1) -or $_.Length -eq 0} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}

Get-ChildItem $PastaSystemProtheus\*.bak | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\*.#db | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\*.#cd | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\*.#cf | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\*.#le | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\*.#ls | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\*.#fp | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\*.#pd | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\*.old | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-7)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\*.~xn | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-7)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\*.tmp | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
#Acho que nao precisa mais Get-ChildItem $PastaSystemProtheus\HSBC*.dat | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-7)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
#Acho que nao precisa mais Get-ChildItem $PastaSystemProtheus\CBR*.dat | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-7)} | ForEach { Move-Item $_.FullName -Destination $PastaLimpezaSystemProtheus}
Get-ChildItem $PastaSystemProtheus\s*.idx | ?{ $_.PSIsContainer } | remove-item -Recurse
Get-ChildItem $PastaSystemProtheus\t*.idx | ?{ $_.PSIsContainer } | remove-item -Recurse


# Compacta arquivos movidos para a pasta de limpeza e depois remove-os.
VA_Log -TipoLog 'info' -MsgLog 'Compactando pasta de limpeza do Protheus'
& $Compactador a -tzip $PastaLimpezaSystemProtheus\Limpeza_$DataHora $PastaLimpezaSystemProtheus\* -x!Limpeza*.zip
Get-ChildItem $PastaLimpezaSystemProtheus\* -exclude *.zip | remove-item -Force


# Limpa relatorios antigos, DANFes, pedidos de compra em PDF, etc. do Protheus.
Get-ChildItem $PastaBaseProtheus\spool\*.* | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-10)} | remove-item -Force
Get-ChildItem $PastaBaseProtheus\TReport\*.* | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-10)} | remove-item -Force
Get-ChildItem $PastaBaseProtheus\generico\*.* | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-10)} | remove-item -Force
Get-ChildItem $PastaBaseProtheus\pedidos\*.pdf | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-2)} | remove-item -Force
Get-ChildItem $PastaBaseProtheus\DirDoc -Recurse -Include sc*.csv | remove-item -Force
Get-ChildItem $PastaBaseProtheus\DirDoc -Recurse -Include sc*.xml | remove-item -Force
Get-ChildItem $PastaBaseProtheus\DirDoc -Recurse -Include ap*.tmp | remove-item -Force
# Esta pasta nao existe mais Get-ChildItem $PastaBaseProtheus\PswBackup | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-30)} | remove-item -recurse  -Force
Get-ChildItem $PastaBaseProtheus\workflow\emp??\mail\*\sent\*\*.wfm | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-5)} | remove-item -Force
Get-ChildItem $PastaBaseProtheus\workflow\emp??\temp\*.htm | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-5)} | remove-item -Force
Get-ChildItem $PastaBaseProtheus\workflow\emp??\process\*.val | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-10)} | remove-item -Force


# Remove RPOs de compilacoes antigas (que nao estiverem em uso).
Get-ChildItem C:\siga\Protheus12\apo_0??? | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-5)} | Remove-Item -Recurse -verbose
Get-ChildItem C:\siga\Protheus12\apo_1??? | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-5)} | Remove-Item -Recurse -verbose
Get-ChildItem C:\siga\Protheus12\apo_2??? | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-5)} | Remove-Item -Recurse -verbose
Get-ChildItem C:\siga\Protheus12\apo_3??? | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-5)} | Remove-Item -Recurse -verbose
Get-ChildItem C:\siga\Protheus12\apo_4??? | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-5)} | Remove-Item -Recurse -verbose
Get-ChildItem C:\siga\Protheus12\apo_5??? | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-5)} | Remove-Item -Recurse -verbose
Get-ChildItem C:\siga\Protheus12\apo_6??? | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-5)} | Remove-Item -Recurse -verbose
Get-ChildItem C:\siga\Protheus12\apo_7??? | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-5)} | Remove-Item -Recurse -verbose
Get-ChildItem C:\siga\Protheus12\apo_8??? | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-5)} | Remove-Item -Recurse -verbose
Get-ChildItem C:\siga\Protheus12\apo_9??? | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-5)} | Remove-Item -Recurse -verbose


# Gera backup diario dos scripts. Pretendo mover todos para o SrvAdm, mas, ateh que fique pronto...
VA_Log -TipoLog 'info' -MsgLog 'Gerando backup dos scripts'
Get-ChildItem c:\util\scripts\logs\*.* | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-7)} | remove-item -Force
#& $Compactador a -r -tzip $PastaBackups\Scripts_Server02_$DataHora c:\util\scripts\*.*
& $Compactador a -r -tzip $PastaBackups\Scripts_$DataHora c:\util\scripts\*.*


# Compacta e apaga arquivos de log da pasta Autocom
VA_Log -TipoLog 'info' -MsgLog "Iniciando backup pasta Autocom"
$result = & $Compactador a -r -tzip ($PastaAutocomProtheus+'\Autocom_'+$DataHora) ($PastaAutocomProtheus+'\*.txt')
if ($result[$result.Length - 1] -eq "Everything is Ok")
{
    Get-ChildItem $PastaAutocomProtheus\*.txt -Recurse | remove-item -Force
}
else
{
    VA_Log -TipoLog 'erro' -MsgLog "Erro na compactacao da pasta Autocom"
}


# Apaga arquivos XML antigos que tenham sido enviados para transportadoras


# Desabilitado por que esteve movendo arquivos antes que fossem processados.
# Move arquivos de XML (do importador da TRS) mais antigos para pasta onde nao sejam mais reprocessados pelo ImportadorXML da Totvs RS.
#va_Log -TipoLog 'info' -MsgLog 'Movendo arquivos XML antigos para pasta \expirado\'
#Get-ChildItem $PastaBaseProtheus\xmlnfe\*.xml | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-90)} | ForEach { Move-Item $_.FullName -Destination $PastaBaseProtheus\xmlnfe\expirado\ -verbose}

# Remove arquivos que o TSS gera quando tem debug habilitado
va_Log -TipoLog 'info' -MsgLog 'Limpando arquivos de debug do TSS'
Get-ChildItem C:\siga\tss\wslogxml\*.* | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-10)} | Remove-Item -Recurse -verbose
Get-ChildItem C:\siga\tss\wsprofiler\*.* | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-10)} | Remove-Item -Recurse -verbose

# Remove logs antigos da pasta TEMP
va_Log -TipoLog 'info' -MsgLog 'Limpando pasta TEMP'
Get-ChildItem C:\temp\*.log | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-15)} | Remove-Item -Recurse -verbose

VA_Log -TipoLog 'info' -MsgLog 'Finalizando execucao'
