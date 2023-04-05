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
	$Running = Get-Process Gerenciador -ErrorAction SilentlyContinue
	
    if ($Running) { 
        Stop-Process -name Gerenciador
    } 
	
    Start-Process "C:\Program Files (x86)\Leucotron Telecom\Sistema Call Center\Módulo Gerenciador de Atendimento\Gerenciador.exe"
    VA_Log -TipoLog 'info' -MsgLog ('Iteracao numero ' + $contadorDeLoops + ' finalizada. Aguardando nova execucao...')
    Start-Sleep (1800)
    $contadorDeLoops ++
} 

while (1 -eq 1)
