# Script de envio de dados para o Zabbix Trapper
# Criado para tratar erros de chave inexistente, etc.
# Autor: Robert Koch
# Data: 17/08/2016
#
# Historico de alteracoes:
# 13/09/2018 - Robert - IP do Zabbix alterado de 192.168.1.7 para 192.168.1.14
# 18/11/2018 - Robert - Recebe como parametro o nome do computador, para poder rodar remotamente.
# 25/08/2021 - Robert - Envia tambem para o Zabbix novo (192.168.1.15)
#

# Para chamar este script direto de outro servidor, deve-se adicionar o host (apenas '192.168.1.12') na lista de sites confiaveis do internet explorer (do computador que vai chamar)

Param ([string]$chave, [string]$dado, [string]$computador)

$result = & C:\util\Zabbix_sender.exe -z 192.168.1.14 -s $computador -k $chave -o $dado

if ($result[0].Contains("failed: 1"))
{
    Write-Output ("[" + $env:COMPUTERNAME + "] Envio para Zabbix --> Erro no envio da chave " + $computador + ":" + $chave + " com valor " + $dado)
#    & C:\Zabbix\Zabbix_sender.exe -z 192.168.1.14 -s $computador -k chaves_com_erro -o ($chave)
    & C:\util\Zabbix_sender.exe -z 192.168.1.14 -s $computador -k chaves_com_erro -o ($chave)
}
else
{
    Write-Output ("[" + $env:COMPUTERNAME + "] Envio para Zabbix --> " + $computador + ":" + $chave + ": " + $dado)
}

# Para limpar o trigger "Erro envio trapper chave..." executar:
# & "C:\Zabbix\Zabbix_sender.exe" -z 192.168.1.14 -s $env:COMPUTERNAME -k chaves_com_erro -o '.'



#####################
# Envia copia para o zabbix novo
#if ($computador -eq 'SERVERPROTHEUS')
#{
    $computador = 'Sistemas'
#}
$result = & C:\util\Zabbix_sender.exe -z 192.168.1.15 -s $computador -k $chave -o $dado
if ($result[0].Contains("failed: 1"))
{
    #Write-Output ("[" + $env:COMPUTERNAME + "] Envio para Zabbix NOVO --> Erro no envio da chave " + $computador + ":" + $chave + " com valor " + $dado)
	Grava-Log("[" + $env:COMPUTERNAME + "] Envio para Zabbix NOVO --> Erro no envio da chave " + $computador + ":" + $chave + " com valor " + $dado)
}
else
{
    #Write-Output ("[" + $env:COMPUTERNAME + "] Envio para Zabbix NOVO --> " + $computador + ":" + $chave + ": " + $dado)
	Grava-Log("[" + $env:COMPUTERNAME + "] Envio para Zabbix NOVO --> " + $computador + ":" + $chave + ": " + $dado)
}
