
$Desc1="Financeiro\Comprovantes_RH"
#$Desc1="Governanca\Novos POPs\POP-JUR"
#$Desc1="Governanca\Novos POPs\POP-SUP"
#$Desc1="Governanca\Novos POPs\POP-CUS"


$GrpName   =  "GrpFinCompRH" 
$GrpDesc   =  $Desc1
$GrpMembros = "andre.oliveira";"franciele.oliveira";"yulli.pereira"

$GrPath    =  "OU=Grupos FileShare,DC=vinhos-alianca,DC=local"
$GrpMembroDe =  "Grp"+$GrpDesc.Split('\')[0]+"_N1"


New-ADGroup -GroupScope Global -Name $GrpName -Description $GrpDesc -path $GrPath
ADD-ADGroupMember $GrpName  -Members $GrpMembros.Split(";")
ADD-ADGroupMember $GrpMembroDe  -Members $GrpName