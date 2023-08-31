






$Desc1 = "Engenharia\Laboratório\REGISTROS DE ANALISES"
$GrpName =  "GrpRegAnalises"

$GrpDesc = $Desc1
$GrpMembros = "daiana.ribas"

$GrPath = "OU=Grupos FileShare,DC=vinhos-alianca,DC=local"
$GrpMembroDe ="Grp"+$GrpDesc.Split('\')[0]+"_N1"


New-ADGroup -GroupScope Global -Name $GrpName -Description $GrpDesc -path $GrPath
ADD-ADGroupMember $GrpName  -Members $GrpMembros.Split(";")
ADD-ADGroupMember $GrpMembroDe  -Members $GrpName