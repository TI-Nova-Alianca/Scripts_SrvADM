






$Desc1="Governanca\Novos POPs\POP-VEN"
$GrpName   =  "GrpPOP_VEN"

$GrpDesc   =  $Desc1
#$GrpMembros = "andre.oliveira";"franciele.oliveira";"yulli.pereira"

$GrPath    =  "OU=Grupos FileShare,DC=vinhos-alianca,DC=local"
$GrpMembroDe ="GrpNovosPOPs" # "Grp"+$GrpDesc.Split('\')[0]+"_N1"


New-ADGroup -GroupScope Global -Name $GrpName -Description $GrpDesc -path $GrPath
#ADD-ADGroupMember $GrpName  -Members $GrpMembros.Split(";")
ADD-ADGroupMember $GrpMembroDe  -Members $GrpName