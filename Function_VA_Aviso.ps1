# Cooperativa Agroindustrial Nova Alianca
# Descricao: Envia aviso / notificacao para usuarios.
# Autor....: Robert Koch
# Data.....: 14/09/2022

# Historico de alteracoes:
#

# ---------------------------------------------------------------------------
Function VA_Aviso
{
    # Dicas boas sobre parametros: https://stackoverflow.com/questions/4988226/how-do-i-pass-multiple-parameters-into-a-function-in-powershell
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [ValidatePattern('info|aviso|erro')]
         [string]$Tipo,
         [Parameter(Mandatory=$true, Position=1)]
         [string]$Titulo,
         [Parameter(Mandatory=$true, Position=2)]
         [string]$Texto,
         [Parameter(Mandatory=$true, Position=3)]
         [string]$Destinatarios,
         [Parameter(Mandatory=$true, Position=4)]
         [string]$Origem
    )

	$DiasDeVida = 1
	if ($Tipo.ToUpper() -eq 'INFO' -or $Tipo.ToUpper() -eq 'I')
	{
		$TipoParaWS = 'I'
		$DiasDeVida = 30
	}
   	elseif ($Tipo.ToUpper() -eq 'AVISO' -or $Tipo.ToUpper() -eq 'A')
	{
		$TipoParaWS = 'A'
		$DiasDeVida = 60
	}
   	elseif ($Tipo.ToUpper() -eq 'ERRO' -or $Tipo.ToUpper() -eq 'E')
	{
		$TipoParaWS = 'E'
		$DiasDeVida = 90
	}
	

	# Envia aviso ao NaWeb via web service.
	$uri = "http://naweb17.novaalianca.coop.br/PrcNotificacoesWS.aspx?wsdl"
	$proxy = New-WebServiceProxy -Uri $uri
	$XMLAviso = '<SdtNotificacoes>'
	$XMLAviso +=    '<SdtNotificacoesItem>'
	$XMLAviso +=    '<NotifTipo>' + $TipoParaWS + '</NotifTipo>'
	$XMLAviso +=    '<NotifTitulo>' + $Titulo + '</NotifTitulo>'
	$XMLAviso +=    '<NotifMsg>' + $Texto + '</NotifMsg>'
	$XMLAviso +=    '<NotifUsuarios>' + $Destinatarios + '</NotifUsuarios>'
	$XMLAviso +=    '<NotifRecorrencia>' + $DiasDeVida + '</NotifRecorrencia>'
	$XMLAviso +=    '<NotifOrigem>[' + $env:COMPUTERNAME + ']' + $Origem + '</NotifOrigem>'
	$XMLAviso +=    '</SdtNotificacoesItem>'
	$XMLAviso += '</SdtNotificacoes>'

    VA_Log -TipoLog 'debug' -MsgLog ('Enviando (via NaWeb) aviso para ' + $Destinatarios + ': ' + $Titulo)
	
	# Executa e mostra resultado
	$RetornoWS = $proxy.Execute($XMLAviso)

    #Write-Host 'Retorno web service:'$RetornoWS

    if ($RetornoWS -ne 'OK')
    {
        VA_Log -TipoLog 'erro' -MsgLog ('Erro ao enviar aviso para NaWeb: ' + $RetornoWS)
    }
	
}
