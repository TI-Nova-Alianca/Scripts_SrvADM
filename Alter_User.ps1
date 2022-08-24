$FileCSV= Import-CSV -Path C:\Util\scripts\ramais.csv
Import-Module ActiveDirectory

Foreach ($Txt in $FileCSV) { 
    
    $User            =$Txt.Nome
    $telephoneNumber =$Txt.Telefone
    $otherTelephone  =$Txt.Celular
    $mail            =$Txt.E-Mail
    $department      =Txt.Departamento

    Get-ADUser -Identity $user | Set-ADUser -OfficePhone $telephoneNumber;
    Get-ADUser -Identity $user | Set-ADUser -Clear otherTelephone;
    Get-ADUser -Identity $user | Set-ADUser -Add @{otherTelephone=$otherTelephone};

}