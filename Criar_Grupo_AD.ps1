
$Desc1="Engenharia\Engenharia do Produto\SAFRA\Documentos Filial 07"
#$Desc1="Governanca\Novos POPs\POP-JUR"
#$Desc1="Governanca\Novos POPs\POP-SUP"
#$Desc1="Governanca\Novos POPs\POP-CUS"


$GrpName   =  "GrpF07DocsSafra" 
$GrpDesc   =  $Desc1
$GrpMembros = "fabiana.busetti";"f07.laboratorio";"balanca.f07"

$GrPath    =  "OU=Grupos FileShare,DC=vinhos-alianca,DC=local"
$GrpMembroDe =  "Grp"+$GrpDesc.Split('\')[0]+"_N1"


New-ADGroup -GroupScope Global -Name $GrpName -Description $GrpDesc -path $GrPath
ADD-ADGroupMember $GrpName  -Members $GrpMembros.Split(";")
ADD-ADGroupMember $GrpMembroDe  -Members $GrpName