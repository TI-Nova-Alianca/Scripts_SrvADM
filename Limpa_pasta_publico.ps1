
<# Agenda tarefa no Windows - Selecione e execute:

$nomeScript = 'Limpa_pasta_publico'
schtasks /create /TN $nomeScript /SC DAILY /ST 00:00 /RI 1400 /DU 24:00  /RU "vinhos-alianca\Administrador" /TR "powershell -file c:\util\scripts\$nomeScript.ps1"

#>

# Limpa arquivos antigos.
#Get-ChildItem 'd:\documentos\publico\'*.* -Recurse | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddMinutes(-30)} | remove-item -Recurse -force
Get-ChildItem 'C:\ProgramData\SmartSync\logs\'*.* -Recurse | where -FilterScript {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-30)} | remove-item -Recurse -force



