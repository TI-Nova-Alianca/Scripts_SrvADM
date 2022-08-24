$OUNova = "OU=Nova Alianca,DC=vinhos-alianca,DC=local"

get-aduser –filter * -property * -SearchBase $OUNova | Select-object user, telephone, department,email | ConvertTo-Csv | Out-File c:\util\scripts\Exportados\Emails-Todos.csv

