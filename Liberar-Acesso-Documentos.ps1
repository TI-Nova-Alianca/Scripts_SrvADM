
<#CRIAR um Novo Grupo no AD#>

<#Definir: Nome do Grupo, Membros do Grupo Ex: ("Membro01","Mebro02"), 
  Descrição ( No caso do FileShare, Setor+ caminho até a pasta), e a OU onde vai ficar o Grupo #>

<#
    $GroupName = read-host "Nome do Grupo"
    $GrpMember = read-host "Mebros do Grupo user01;user02"
    $GroupDesc = read-host "Descrição do Grupo (Setor\pasta\subpasta)"
    $OUGrpFileShere = "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"

#Criar um Grupo novo no AD
   
   New-ADGroup -Name $GroupName -Description $GroupDesc -GroupScope Global -path $OUGrpFileShere 
    
#Inserir Mebros no Grupo Criado
   
    ADD-ADGroupMember $GroupName  -Members $GrpMember.Split(";")

#>
<#

#Definir permissões em uma Pasta 
    $GroupName   = "" 
    $Setor       = ""
    $SubFolder   = ""
    $SubFolder2  = ""
    
    $Pasta       = "D:\Documentos\"+$Setor
    $Subpasta    = $Pasta + "\" + $SubFolder 
    $Subpasta2   = $Subpasta + "\" + $SubFolder2 

    $ACLPasta      = Get-Acl $Pasta
    $ACLSubpasta   = Get-Acl $Subpasta
    $ACLSubpasta2  = Get-Acl $Subpasta2
    

    $ACLRulePasta    = New-Object System.Security.AccessControl.FileSystemAccessRule($GroupName,"Read","None", "InheritOnly", "Allow")
    $ACLRuleSubpasta  = New-Object System.Security.AccessControl.FileSystemAccessRule($GroupName,"Read","None", "InheritOnly", "Allow")
    $ACLRuleSubpasta2 = New-Object System.Security.AccessControl.FileSystemAccessRule("$GroupName","Modify","ContainerInherit, ObjectInherit","None","Allow")

    $ACLPasta.AddAccessRule($ACLRulePasta)
    $ACLSubpasta.AddAccessRule($ACLRuleSubpasta)
    $ACLSubpasta2.AddAccessRule($ACLRuleSubpasta2)

    Set-Acl $Pasta $ACLPasta
    Set-ACL $Subpasta $ACLSubpasta
    Set-ACL $Subpasta2 $ACLSubpasta2

#>

New-ADGroup -Name GrpAgronomia_N1		-Description Agronomia		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpAmbiental_N1       -Description Ambiental		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpComercial_N1       -Description Comercial		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpCompras_N1         -Description Compras		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpContabilidade_N1   -Description Contabilidade	-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpControladoria_N1   -Description Controladoria	-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpCooperativa_N1     -Description Cooperativa	-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpCustos_N1          -Description Custos			-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpDiretoria_N1       -Description Diretoria		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpdptTecnico_N1      -Description dptTecnico		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpFinanceiro_N1      -Description Financeiro		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpFiscal_N1          -Description Fiscal			-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpGovernanca_N1      -Description Governanca		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpInformatica_N1     -Description Informatica	-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpJuridico_N1        -Description Juridico		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpLogistica_N1       -Description Logistica		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpManufatura_N1      -Description Manufatura		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpManutencao_N1      -Description Manutencao		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpMarketing_N1       -Description Marketing		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpPCP_N1             -Description PCP			-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpPortaria_N1        -Description Portaria		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpProcessos_N1       -Description Processos		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpRecepcao_N1        -Description Recepcao		-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpRH_N1              -Description RH				-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpSAC_N1             -Description SAC			-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"
New-ADGroup -Name GrpSeg-Trabalho_N1    -Description Seg-Trabalho 	-GroupScope Global -path "OU=Grupos FileShere,DC=vinhos-alianca,DC=local"