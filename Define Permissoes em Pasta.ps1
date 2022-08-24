
$Pasta_Grupo     = Import-CSV -Path C:\util\N1.csv

$GrpPath    =  "OU=Grupos FileShare,DC=vinhos-alianca,DC=local"

<#
Foreach ($CSV1 in $Pasta_Grupo) {
    New-ADGroup -GroupScope Global -Name $CSV1.Grupo -Description $CSV1.Pasta -path $GrpPath
    ADD-ADGroupMember $CSV1.Grupo  -Members $CSV1.Membros.Split(";")
    $GrpMembroDe =  "Grp"+$CSV1.Pasta.Split('\')[0]+"_N1"
    ADD-ADGroupMember $GrpMembroDe  -Members $CSV1.Grupo
   exit

}
#>



 

    Foreach ($CSV in $Pasta_Grupo) {
    $Permi_Ler =       New-Object System.Security.AccessControl.FileSystemAccessRule("$CSV.Grupo","Read","None", "InheritOnly", "Allow");
    $Permi_Modificar = New-Object System.Security.AccessControl.FileSystemAccessRule("$CSV.Grupo","Modify","ContainerInherit, ObjectInherit","None","Allow")
    
    $Pasta =  $CSV.Pasta;
    $ACLPasta = Get-Acl  $Pasta;
    
    
    If ($CSV.Permissao -eq "Ler"){$Permissao2=$Permi_Ler}
    If ($CSV.Permissao -eq "Modificar"){$Permissao2=$Permi_Modificar}
  #$Permissao2.FileSystemRights
  $ACLPasta.AddAccessRule($Permissao2);
  Set-Acl $Pasta $ACLPasta;  
   Exit
}









<#
Foreach ($CSV in $Pasta_Grupo) {
    
    $Permi_Ler       = New-Object System.Security.AccessControl.FileSystemAccessRule("$CSV.Grupo","Read","None", "InheritOnly", "Allow");
    $Permi_Modificar = New-Object System.Security.AccessControl.FileSystemAccessRule("$CSV.Grupo","Modify","ContainerInherit, ObjectInherit","None","Allow")
    $Pasta1="D:\Documentos\"+$CSV.Pasta;
    $Pasta1

    If ($CSV.Permissao -eq "Ler") {$Permissao2=$Permi_Ler}
    If ($CSV.Permissao -eq "Modificar") {$Permissao2=$Permi_Modificar}
    $ACLPasta = Get-Acl  $Pasta1
    $ACLPasta.AddAccessRule($Permissao2);
    Set-Acl $Pasta1 $ACLPasta;  
  
}
#>