
#Definição de Variaveis
	$OUNov =	"OU=Administrativo,OU=Nova Alianca,DC=vinhos-alianca,DC=local"
    $OUNov1 =	"OU=Industrial,OU=Nova Alianca,DC=vinhos-alianca,DC=local"
    #$OUNov2 =	"OU=Restaurante Parus,OU=ldap,DC=vinhos-alianca,DC=local"


#Exportar Emails Todos os colaboradores 
	Get-ADObject -filter * -Properties * -SearchBase $OUNov | Select-Object userPrincipalName | ConvertTo-Csv | Out-File c:\util\scripts\Exportados\rst1.csv
    Get-ADObject -filter * -Properties * -SearchBase $OUNov1 | Select-Object userPrincipalName | ConvertTo-Csv | Out-File c:\util\scripts\Exportados\rst2.csv
