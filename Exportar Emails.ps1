
#Definição de Variaveis
	#$OUAdm =	"OU=Administrativo,OU=Nova Alianca,DC=vinhos-alianca,DC=local"
    #$OUInd =	"OU=Industrial,OU=Nova Alianca,DC=vinhos-alianca,DC=local"
    $OUNova = "OU=Nova Alianca,DC=vinhos-alianca,DC=local"


	

#Exportar Emails Todos os colaboradores 
	dsquery user -limit 0
    
    
    #Get-ADObject -filter * -Properties Get-ADGroupMember -Identity 'GrpAdministrativo'  | Select-Object mail| ConvertTo-Csv | Out-File c:\util\scripts\Exportados\Emails-Adm.csv
    #Get-ADObject -filter * -Properties * -SearchBase $OUInd  | Select-Object mail| ConvertTo-Csv | Out-File c:\util\scripts\Exportados\Emails-Ind.csv
    
    Get-ADObject -filter * -Properties * -SearchBase $OUNova | Select-Object mail, name| ConvertTo-Csv | Out-File c:\util\scripts\Exportados\Emails-Todos.csv
    #dsquery group -name "GrpAdministrativo" | dsget group -members -expand | dsget user -description -email  > c:\util\emails.txt
    
  #Search-ADAccount �PasswordNeverExpires -SearchBase $OUNova | Select -Property * |Export-CSV "C:\temp\PasswordNeverExpireADUsers.csv" -NoTypeInformation -Encoding UTF8


  #Get-ADUser -Filter * -Properties *   -SearchBase $OUNova | Select-Object *| ConvertTo-Csv | Out-File C:\temp\PasswordNeverExpireADUsers.csv

  #Get-ADUser -Filter * -Properties * | Select-Object name | export-csv -path c:\export\allusers.scv

