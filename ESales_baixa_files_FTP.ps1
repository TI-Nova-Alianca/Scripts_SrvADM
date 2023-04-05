# Autor: Fabiano Fernandes
# Data: 2017
# Baixa arquivos da E-Sales
#
# Historico de alteracoes:
# 08/11/2017 - Robert - Baixa *.TXT e *.XML em pastas diferentes.
# 20/11/2017 - Robert - Invertidos nomes de pastas do FTP (passa a buscar de envia_embarcador e nao mais de recebe_embarcador) a pedido do Sr. Paulo (desenvolvimento E-Sales).
# 06/11/2019 - Robert - Ajuste caminho para baixar CTe e OCOREN (solicitamos `a E-Sales para enviarem as ocorrencias e foi criada uma pasta para cada uma no FTP).
# 25/03/2021 - Robert - Adicionado parametro -verbose e mostra data/hora da execucao para logs de acompanhamento.
# 17/11/2021 - Robert - Inseridos alguns 'sleeps' para teste, por que parecia estar apagando arquivos antes de baixa-los.
# 18/09/2022 - Robert - Migrado para pasta compartilhada no SrvAdm
#                     - Passa a usar rotinas compartilhadas de log e aviso.
#

<#
# Envia log para servidor ElasticSearch
# Autor: Robert Koch
# Data: 18/01/2022
# Historico de alteracoes:
#
Function LogES
{
    Param([string]$tipoLogES, [string]$msgLogES)
#    $PastaLogs = 'C:\temp\'

    # Dica para pegar o nome do script encontrada em https://stackoverflow.com/questions/817198/how-can-i-get-the-current-powershell-executing-file
    # Parece nao funcionar quando se executa direto do ISE.
    $ScriptInvocation = (Get-Variable MyInvocation -Scope Script).Value
    $ScriptName = $ScriptInvocation.MyCommand.Name
    $ScriptName = $ScriptName.Replace('.ps1', '')

#    $ArqLog = $ScriptName+'_'+(Get-Date -Format yyyyMMdd)+".log"
#    $DataHora = Get-Date -Format yyyyMMdd-HH:mm:ss
#    $stack = Get-PSCallStack
#    $gravar = '['+$tipo+']['+$DataHora + "][" + [Environment]::UserName + "][" + $stack[1].Location + "] " + $msg
#    write-host $msg
    
    # Prepara dados para envio ao ES
    $paramES = @{
        Uri         = "http://192.168.1.2:9200/robert2/elasticsearch"
        Method      = "Post"
        Body        = '{"tipo":"' + $tipoLogES + '",
                        "aplicacao":"PowerShell",
                        "usr":"' + [Environment]::UserName + '",
                        "thread":"' + [System.Threading.Thread]::CurrentThread.ManagedThreadId + '",
                        "host":"' + $env:COMPUTERNAME + '",
                        "script":"' + $ScriptName + '",
                        "msg":"' + $msgLogES + '"
                   }'
        ContentType = "application/json"
    }
    Invoke-RestMethod @paramES
}
#>

# Importa arquivos de funcoes via 'dot source' para que as funcoes possam ser usadas aqui.
. '\\SRVADM\c$\util\Scripts\Function_VA_Log.ps1'
. '\\SRVADM\c$\util\Scripts\Function_VA_Aviso.ps1'

VA_Log -TipoLog 'info' -MsgLog 'Iniciando execucao'
#LogES('info', 'Iniciando execucao da rotina')

Import-Module PSFTP
$FTPServer = '200.9.174.224'
$FTPUsername= 'nova.alianca'
$FTPPassword = '6252xb1H'
$FTPSecurePassword = ConvertTo-SecureString -String $FTPPassword -asPlainText -Force
$FTPCredential = New-Object System.Management.Automation.PSCredential($FTPUsername,$FTPSecurePassword)
Set-FTPConnection -Credentials $FTPCredential -Server $FTPServer -Session MySession -UsePassive
$Session = Get-FTPConnection -Session MySession

Get-FTPChildItem -Session $Session -Path /envia_embarcador -Filter CON*.txt | Get-FTPItem -Session $Session -LocalPath "C:\Siga\Protheus12\protheus_data\EDI_CONH\CONEMB" -verbose
Get-FTPChildItem -Session $Session -Path /envia_embarcador -Filter CON*.txt | Remove-FTPItem -Session $Session

Get-FTPChildItem -Session $Session -Path /envia_embarcador/CTe/ -Filter *.xml | Get-FTPItem -Session $Session -LocalPath "C:\Siga\Protheus12\protheus_data\xml_NFe\CT-e" -verbose
Get-FTPChildItem -Session $Session -Path /envia_embarcador/CTe/ -Filter *.xml | Remove-FTPItem -Session $Session

# Andei perdendo arquivos em nov/2021. Vou tentar dar um tempo para ver se melhora.
start-sleep 5
Get-FTPChildItem -Session $Session -Path /envia_embarcador/OcorEn -Filter *.txt | Get-FTPItem -Session $Session -LocalPath "C:\Siga\Protheus12\protheus_data\PROCEDA" -verbose
start-sleep 5
Get-FTPChildItem -Session $Session -Path /envia_embarcador/OcorEn -Filter *.txt | Remove-FTPItem -Session $Session
start-sleep 5

VA_Log -TipoLog 'info' -MsgLog 'Finalizando execucao'

#LogES('info', 'Finalizando execucao da rotina')
