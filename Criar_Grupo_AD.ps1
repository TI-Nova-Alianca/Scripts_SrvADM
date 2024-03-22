






$Desc1 = "Agronomia\LOCAL GAP"
$GrpName =  "GrpAgroGAP"

$GrpDesc = $Desc1
$GrpMembros = "eliane.lopes";"michele.frigotto"

$GrPath = "OU=Grupos FileShare,DC=vinhos-alianca,DC=local"
$GrpMembroDe ="Grp"+$GrpDesc.Split('\')[0]+"_N1"


New-ADGroup -GroupScope Global -Name $GrpName -Description $GrpDesc -path $GrPath
ADD-ADGroupMember $GrpName  -Members $GrpMembros.Split(";")
ADD-ADGroupMember $GrpMembroDe  -Members $GrpName