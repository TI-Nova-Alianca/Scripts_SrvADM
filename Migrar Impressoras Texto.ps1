###INICIO Comando DEP-TECNICO/LABOR ####
$WSN  = (New-Object -ComObject WScript.Network)
$WSN2 = (New-Object -ComObject WScript.Network).EnumPrinterConnections()
$SERVERADM = "\\192.168.1.5\" 
$SRVADM    = "\\192.168.1.12\"
$PrinterDEPT = "192.168.2.218"
if ( $WSN2 -contains "192.168.2.218" ) {$WSN.RemovePrinterConnection($SERVERADM+"Dep-Tecnico") + $WSN.AddWindowsPrinterConnection($SRVADM+"Dep-Tecnico")}
$WSN.SetDefaultPrinter($SRVADM+"Dep-Tecnico")
control printers
###FIM Comando DEP-TECNICO/LABOR  ####

$PrinterMANU = "192.168.2.216"
$PrinterALM  = "192.168.2.226"

#Listar as impressoras Instaladas
$WSN2
#Ler a Lista de impressoras e Remover a Impressora do SRVADM e ADICIONAR A MESMA pelo SRVADM
if ( $WSN2 -contains "192.168.2.216" ) {$WSN.RemovePrinterConnection($SERVERADM+"Manutencao")     + $WSN.AddWindowsPrinterConnection($SRVADM+"Manutencao")}
if ( $WSN2 -contains "192.168.2.219" ) {$WSN.RemovePrinterConnection($SERVERADM+"RH")             + $WSN.AddWindowsPrinterConnection($SRVADM+"RH")}
if ( $WSN2 -contains "192.168.2.226" ) {$WSN.RemovePrinterConnection($SERVERADM+"Almoxarifado")   + $WSN.AddWindowsPrinterConnection($SRVADM+"Almoxarifado")}


###INICIO Comando FINANCEIRO ####
$WSN  = (New-Object -ComObject WScript.Network)
$WSN2 = (New-Object -ComObject WScript.Network).EnumPrinterConnections()
$SERVERADM = "\\192.168.1.5\" 
$SRVADM    = "\\192.168.1.12\"
$PrinterFIN  = "192.168.2.217"
if ( $WSN2 -contains "192.168.2.217" ) {$WSN.RemovePrinterConnection($SERVERADM+"Financeiro") + $WSN.AddWindowsPrinterConnection($SRVADM+"Financeiro")}
if ( $WSN2 -contains "192.168.2.214" ) {$WSN.RemovePrinterConnection($SERVERADM+"Administrativo")
if ( $WSN2 -notcontains "192.168.2.217" ) {$WSN.AddWindowsPrinterConnection($SRVADM+"Financeiro")}
$WSN.SetDefaultPrinter($SRVADM+"Financeiro")
control printers
###FIM Comando FINANCEIRO ####

###INICIO Comando COMERCIAL/MKT  ####
$WSN  = (New-Object -ComObject WScript.Network)
$WSN2 = (New-Object -ComObject WScript.Network).EnumPrinterConnections()
$SERVERADM = "\\192.168.1.5\" 
$SRVADM    = "\\192.168.1.12\"
$PrinterCOM  = "192.168.2.220"
if ( $WSN2 -contains "192.168.2.220" ) {$WSN.RemovePrinterConnection($SERVERADM+"Comercial") + $WSN.AddWindowsPrinterConnection($SRVADM+"Comercial")}
$WSN.SetDefaultPrinter($SRVADM+"Comercial")
control printers
###FIM Comando COMERCIAL/MKT  ####

###INICIO Comando  RH ####
$WSN  = (New-Object -ComObject WScript.Network)
$WSN2 = (New-Object -ComObject WScript.Network).EnumPrinterConnections()
$SERVERADM = "\\192.168.1.5\" 
$SRVADM    = "\\192.168.1.12\"
$PrinterRH   = "192.168.2.219"
if ( $WSN2 -contains "192.168.2.219" ) {$WSN.RemovePrinterConnection($SERVERADM+"RH") + $WSN.AddWindowsPrinterConnection($SRVADM+"RH")}
$WSN.SetDefaultPrinter($SRVADM+"RH")
control printers
###FIM Comando RH ####

###Comando para Administrativo####
$WSN  = (New-Object -ComObject WScript.Network)
$WSN2 = (New-Object -ComObject WScript.Network).EnumPrinterConnections()
$SERVERADM = "\\192.168.1.5\" 
$SRVADM    = "\\192.168.1.12\"
$PrinterADM  = "192.168.2.214"
$PrinterFIN  = "192.168.2.217"
if ( $WSN2 -contains "192.168.2.214" ) {$WSN.RemovePrinterConnection($SERVERADM+"Administrativo") + $WSN.AddWindowsPrinterConnection($SRVADM+"Administrativo")}
$WSN.SetDefaultPrinter($SRVADM+"Administrativo")
$WSN2 = (New-Object -ComObject WScript.Network).EnumPrinterConnections()
control printers
###FIM Comando para Administrativo####

###INICIO Comando PORTARIA  ####
$WSN  = (New-Object -ComObject WScript.Network)
$WSN2 = (New-Object -ComObject WScript.Network).EnumPrinterConnections()
$SERVERADM = "\\192.168.1.5\" 
$SRVADM    = "\\192.168.1.12\"
$PrinterPORT = "192.168.2.215"
if ( $WSN2 -contains "192.168.2.215" ) {$WSN.RemovePrinterConnection($SERVERADM+"Portaria") + $WSN.AddWindowsPrinterConnection($SRVADM+"Portaria")}
$WSN.SetDefaultPrinter($SRVADM+"Portaria")
control printers
###FIM Comando PORTARIA  ####

###INICIO Comando LOGISTICA  ####
$WSN  = (New-Object -ComObject WScript.Network)
$WSN2 = (New-Object -ComObject WScript.Network).EnumPrinterConnections()
$SERVERADM = "\\192.168.1.5\" 
$SRVADM    = "\\192.168.1.12\"
$PrinterLOG  = "192.168.2.221"
if ( $WSN2 -contains "192.168.2.221" ) {$WSN.RemovePrinterConnection($SERVERADM+"Logistica") + $WSN.AddWindowsPrinterConnection($SRVADM+"Logistica")}
$WSN.SetDefaultPrinter($SRVADM+"Logistica")
control printers
###FIM Comando LOGISTICA  ####

###INICIO Comando ASSOCIADOS  ####
$WSN  = (New-Object -ComObject WScript.Network)
$WSN2 = (New-Object -ComObject WScript.Network).EnumPrinterConnections()
$SERVERADM = "\\192.168.1.5\" 
$SRVADM    = "\\192.168.1.12\"
$PrinterASS  = "192.168.2.213"
if ( $WSN2 -contains "192.168.2.213" ) {$WSN.RemovePrinterConnection($SERVERADM+"Associados")     + $WSN.AddWindowsPrinterConnection($SRVADM+"Associados")}
$WSN.SetDefaultPrinter($SRVADM+"Associados")
control printers
###FIM Comando ASSOCIADOS  ####

###INICIO Comando AGRONOMIA ####
$WSN  = (New-Object -ComObject WScript.Network)
$WSN2 = (New-Object -ComObject WScript.Network).EnumPrinterConnections()
$SERVERADM = "\\192.168.1.5\" 
$SRVADM    = "\\192.168.1.12\"
$PrinterAGR  = "192.168.2.224"
if ( $WSN2 -contains "192.168.2.224" ) {$WSN.RemovePrinterConnection($SERVERADM+"Agronomia") + $WSN.AddWindowsPrinterConnection($SRVADM+"Agronomia")}
$WSN.SetDefaultPrinter($SRVADM+"Agronomia")
control printers
###FIM Comando AGRONOMIA  ####

###INICIO Comando PCP/Qualidade ####
$WSN  = (New-Object -ComObject WScript.Network)
$WSN2 = (New-Object -ComObject WScript.Network).EnumPrinterConnections()
$SERVERADM = "\\192.168.1.5\" 
$SRVADM    = "\\192.168.1.12\"
$PrinterPCP  = "192.168.2.222"
if ( $WSN2 -contains "192.168.2.222" ) {$WSN.RemovePrinterConnection($SERVERADM+"PCP") + $WSN.AddWindowsPrinterConnection($SRVADM+"PCP")}
$WSN.SetDefaultPrinter($SRVADM+"PCP")
control printers
###FIM Comando PCP/Qualidade  ####

###INICIO Comando PROCESSOS ####
$WSN  = (New-Object -ComObject WScript.Network)
$WSN2 = (New-Object -ComObject WScript.Network).EnumPrinterConnections()
$SERVERADM = "\\192.168.1.5\" 
$SRVADM    = "\\192.168.1.12\"
$PrinterMEP  = "192.168.2.223"
if ( $WSN2 -contains "192.168.2.223" ) {$WSN.RemovePrinterConnection($SERVERADM+"Processos") + $WSN.AddWindowsPrinterConnection($SRVADM+"Processos")}
$WSN.SetDefaultPrinter($SRVADM+"Processos")
control printers
###FIM Comando PROCESSOS  ####

###INICIO Comando DEP-TECNICO/LABOR ####
$WSN  = (New-Object -ComObject WScript.Network)
$WSN2 = (New-Object -ComObject WScript.Network).EnumPrinterConnections()
$SERVERADM = "\\192.168.1.5\" 
$SRVADM    = "\\192.168.1.12\"
$PrinterDEPT = "192.168.2.218"
if ( $WSN2 -contains "192.168.2.218" ) {$WSN.RemovePrinterConnection($SERVERADM+"Dep-Tecnico") + $WSN.AddWindowsPrinterConnection($SRVADM+"Dep-Tecnico")}
$WSN.SetDefaultPrinter($SRVADM+"Dep-Tecnico")
control printers
###FIM Comando DEP-TECNICO/LABOR  ####