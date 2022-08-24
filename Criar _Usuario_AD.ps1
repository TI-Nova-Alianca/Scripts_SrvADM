$UserAccounts= Import-CSV -Path d:\documentos\informatica\infra\AddUserAD.csv
Import-Module ActiveDirectory

Foreach ($User in $UserAccounts) { 
$Filial       = $User.Filial
$Departamento = $User.Departamento
$CPF          = $User.CPF
$PrimeNome 	  = $User.PrimeNome
$UltimoNome   = $User.UltimoNome
$Descricao    = $User.Descricao
$Telefone     = $User.Telefone
$Local        = $User.Local
$NomedaConta  = $User.PrimeNome.ToLower()+"."+$User.UltimoNome.ToLower()      
$Usuario      = $User.PrimeNome.ToLower()+"."+$User.UltimoNome.ToLower()+"@novaalianca.coop.br"
$Nome 		  = $User.PrimeNome+" "+$User.UltimoNome
If($User.TemEmail -like "Sim"){ $Email = $Usuario  } Else { $Email = ""} 
New-ADUser -Path $Local -Name $Nome -UserPrincipalName $Usuario -sAMAccountName $NomedaConta -displayName $Nome  -GivenName $PrimeNome -Surname $UltimoNome -Department $Departamento  -EmailAddress $Email -employeeID $CPF -description $Descricao -OfficePhone $Telefone -Office $Filial  -Enabled $true -PasswordNotRequired $True 
$Nome

}




