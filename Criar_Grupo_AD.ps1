






$Desc1 = "Cooperativa\Unimed Associados"
$GrpName =  "GrpCoopUniAssoc"

$GrpDesc = $Desc1
$GrpMembros = "fabiana.busetti"

$GrPath = "OU=Grupos FileShare,DC=vinhos-alianca,DC=local"
$GrpMembroDe ="Grp"+$GrpDesc.Split('\')[0]+"_N1"


New-ADGroup -GroupScope Global -Name $GrpName -Description $GrpDesc -path $GrPath
ADD-ADGroupMember $GrpName  -Members $GrpMembros.Split(";")
ADD-ADGroupMember $GrpMembroDe  -Members $GrpName