#Declaracao de Váriaveis e seus Atributos
$WSN  = (New-Object -ComObject WScript.Network)
$WSN2 = (New-Object -ComObject WScript.Network).EnumPrinterConnections()
$SRVADM    = "\\192.168.1.12\"
$SERVERADM = "\\192.168.1.5\" 
$PrinterASS  = "192.168.2.213"
$PrinterADM  = "192.168.2.214"
$PrinterPORT = "192.168.2.215"
$PrinterMANU = "192.168.2.216"
$PrinterFIN  = "192.168.2.217"
$PrinterDEPT = "192.168.2.218"
$PrinterRH   = "192.168.2.219"
$PrinterCOM  = "192.168.2.220"
$PrinterLOG  = "192.168.2.221"
$PrinterPCP  = "192.168.2.222"
$PrinterMEP  = "192.168.2.223"
$PrinterAGR  = "192.168.2.224"
$PrinterALM  = "192.168.2.226"

#Listar as impressoras Instaladas
$WSN2
#Ler a Lista de impressoras e Remover a Impressora do SRVADM e ADICIONAR A MESMA pelo SRVADM

if ( $WSN2 -contains "192.168.2.213" ) {$WSN.RemovePrinterConnection($SERVERADM+"Associados")     + $WSN.AddWindowsPrinterConnection($SRVADM+"Associados")}
if ( $WSN2 -contains "192.168.2.214" ) {$WSN.RemovePrinterConnection($SERVERADM+"Administrativo") + $WSN.AddWindowsPrinterConnection($SRVADM+"Administrativo")}
if ( $WSN2 -contains "192.168.2.215" ) {$WSN.RemovePrinterConnection($SERVERADM+"Portaria")       + $WSN.AddWindowsPrinterConnection($SRVADM+"Portaria")}
if ( $WSN2 -contains "192.168.2.216" ) {$WSN.RemovePrinterConnection($SERVERADM+"Manutencao")     + $WSN.AddWindowsPrinterConnection($SRVADM+"Manutencao")}
if ( $WSN2 -contains "192.168.2.217" ) {$WSN.RemovePrinterConnection($SERVERADM+"Financeiro")     + $WSN.AddWindowsPrinterConnection($SRVADM+"Financeiro")}
if ( $WSN2 -contains "192.168.2.218" ) {$WSN.RemovePrinterConnection($SERVERADM+"Dep-Tecnico")    + $WSN.AddWindowsPrinterConnection($SRVADM+"Dep-Tecnico")}
if ( $WSN2 -contains "192.168.2.219" ) {$WSN.RemovePrinterConnection($SERVERADM+"RH")             + $WSN.AddWindowsPrinterConnection($SRVADM+"RH")}
if ( $WSN2 -contains "192.168.2.220" ) {$WSN.RemovePrinterConnection($SERVERADM+"Comercial")      + $WSN.AddWindowsPrinterConnection($SRVADM+"Comercial")}
if ( $WSN2 -contains "192.168.2.221" ) {$WSN.RemovePrinterConnection($SERVERADM+"Logistica")      + $WSN.AddWindowsPrinterConnection($SRVADM+"Logistica")}
if ( $WSN2 -contains "192.168.2.222" ) {$WSN.RemovePrinterConnection($SERVERADM+"PCP")            + $WSN.AddWindowsPrinterConnection($SRVADM+"PCP")}
if ( $WSN2 -contains "192.168.2.223" ) {$WSN.RemovePrinterConnection($SERVERADM+"Processos")      + $WSN.AddWindowsPrinterConnection($SRVADM+"Processos")}
if ( $WSN2 -contains "192.168.2.224" ) {$WSN.RemovePrinterConnection($SERVERADM+"Agronomia")      + $WSN.AddWindowsPrinterConnection($SRVADM+"Agronomia")}
if ( $WSN2 -contains "192.168.2.226" ) {$WSN.RemovePrinterConnection($SERVERADM+"Almoxarifado")   + $WSN.AddWindowsPrinterConnection($SRVADM+"Almoxarifado")}

$WSN2 = (New-Object -ComObject WScript.Network).EnumPrinterConnections()
$WSN 
$WSN2