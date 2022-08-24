# Script para (des)bloqueio de usuarios no A.D. com base nos dados do Metadados.
# As matriculas devem estar informadas no campo 'EmployeeId' do cadastro do usuario no A.D. no formato 'Matricula xxxx'
# Autor: Robert Koch
# Data:  08/01/2020
#
# Historico de alteracoes:
# 29/01/2020 - Robert - Passa a verificar a matricula no atributo EmployeeId
#                     - Tratamento para mais de uma conta com mesma matricula (ex: smartphones)
#                     - Melhorado log de execucao
# 28/02/2020 - Robert - Passa a validar o campo CONTRATO e nao mais CRACHA na view do Metadados.
# 03/03/2020 - Robert - Passa a validar o campo CPF (pode haver repeticao de matriculas em diferentes filiais no Metadados).
# 31/07/2020 - Robert - Nunca bloqueava guilherme.oliveira por que a conta era usada no NAMob/NAWeb. Agora nao deve mais ter problema.
# 11/10/2020 - Robert - Passa a pegar funcao de gravacao de log pronta em arquivo externo.
# 12/11/2020 - Robert - Passa a aceitar 'CPF' e 'Pessoa' como chaves no EmployeeID
#

dica: https://fluig.totvsrs.com.br/portal/1/inscricao-evento?e=934

# Importa arquivos de funcoes via 'dot source' para que as funcoes possam ser usadas aqui.
. C:\util\Scripts\Function_Grava-Log.ps1

# -----------------------------------------------------------------
$QtUsers = 0

Grava-Log('Iniciando execucao')

# lista conteudo atual:  Get-aduser -filter * -Properties employeeid | Select-Object name, employeeid


# Busca matriculas no Metadados. Usa credencial de 'consultas' para conectar ao SQL
$SQLUser = "consultas"
$Password = "consultas" | ConvertTo-SecureString -AsPlainText -Force
$Password.MakeReadOnly()
$cred = New-Object System.Data.SqlClient.SqlCredential($SQLUser,$Password)
$connection = new-object System.Data.SqlClient.SQLConnection("Data Source=SrvMeta;Initial Catalog=SIRH");
$connection.credential = $cred
$connection.Open();
$query  = "SELECT CPF, SITUACAO, EM_FERIAS, NOME, isnull (OP05, '1'), PESSOA"
$query +=  " FROM VA_VFUNCIONARIOS"
$query += " ORDER BY NOME"
$cmd = new-object System.Data.SqlClient.SqlCommand($query, $connection);
$reader = $cmd.ExecuteReader()
while ($reader.Read())
{
    $CPF       = $reader.GetValue(0)
    $Situacao  = $reader.GetValue(1)
    $Em_ferias = $reader.GetValue(2)
    $Nome      = $reader.GetValue(3)
    $op05      = $reader.GetValue(4)
    $PessoaRH  = $reader.GetValue(5)
#    $Filtro    = 'CPF ' + $CPF
    $Filtro1   = 'CPF ' + $CPF
    $Filtro2   = 'Pessoa ' + $PessoaRH
    
    # Cria uma lista de usuarios por que pode haver mais de um usuario por pessoa (smartphones, por exemplo)
    # O criterio para encontrar eh ter informado, no campo EmployeeId do A.D., uma das seguintes opcoes:
    # - CPF (deve iniciar por 'CPF ')
    # - codigo de pessoa noMetadados (deve iniciar por 'Pessoa ')
#    $Users = @(get-aduser -Filter 'EmployeeId -eq $Filtro')
    $Users = @(get-aduser -Filter 'EmployeeId -eq $Filtro1') + @(get-aduser -Filter 'EmployeeId -eq $Filtro2')
    foreach ($User in $Users)
    {

        # Migrando alguns usuarios para o novo script. Os demais ainda permanecem aqui.
        if ($User.SamAccountName -eq 'andre.oliveira' -or
            $User.SamAccountName -eq 'claudia.lionco' -or
            $User.SamAccountName -eq 'daiana.ribas' -or
            $User.SamAccountName -eq 'sandra.sugari')
        {
            # Vao ser verificados no novo script
        }
        else
        {

            write-host $User.SamAccountName

            # Define o que deve ser feito com este usuario, conforme CodigoComplementar:
            # 1 = conforme situacao da folha (ativo/demitido/afastado/ferias/...)
            # 2 = bloquear (vai ser demitido / encontra de atestado / ...)
            # 3 = nunca bloquear (diretoria, etc.)
            if ($op05 -eq '1')
            {
                if ($Situacao -ne '1' -or $Em_ferias -eq 'S')
                {
                    $oQueFazer = 'B'
                }
                else
                {
                    $oQueFazer = 'L'
                }
            }
            elseif ($op05 -eq '2')
            {
                $oQueFazer = 'B'  # Bloquear
            }
            elseif ($op05 -eq '3')
            {
                $oQueFazer = 'L'  # Liberar
            }

            if ($oQueFazer -eq 'B')
            {
                if ($User.Enabled)
                {
                    Grava-log ('Bloqueando usuario ' + $User.SamAccountName + ' (matricula: ' + $CPF + ' ' + $Nome + ')')
                    $User | Disable-ADAccount
                }
            }
            else
            {
                if (-not $User.Enabled)
                {
                    Grava-log ('Desbloqueando usuario ' + $User.SamAccountName + ' (matricula: ' + $CPF + ' ' + $Nome + ')')
                    $User | Enable-ADAccount
                }
            }
            $QtUsers ++
        }
    }
}
$reader.Close()
Grava-Log('Finalizando execucao. ' + $QtUsers.ToString() + ' contas verificadas.')


<#
# Copia matricula para outro campo de atributo
$Users = @(get-aduser -Filter * -properties description)
foreach ($User in $Users)
{
    write-host $User.Name
    set-aduser $User -EmployeeID 0
    if ($User.description -like 'Matricula*')
    {
        write-host $User.description
        set-aduser $User -EmployeeID $User.Description
    }
}
#>


<#
# Troca matricula por CPF no atributo EmployeeId
$SQLUser = "consultas"
$Password = "consultas" | ConvertTo-SecureString -AsPlainText -Force
$Password.MakeReadOnly()
$cred = New-Object System.Data.SqlClient.SqlCredential($SQLUser,$Password)
$connection = new-object System.Data.SqlClient.SQLConnection("Data Source=SrvMeta;Initial Catalog=SIRH");
$connection.credential = $cred
$connection.Open();
$Users = @(get-aduser -Filter * -properties EmployeeID)
foreach ($User in $Users)
{
    write-host ''
    write-host 'verificando '$User.Name
    if ($User.EmployeeID -like 'Matricula*')
    {
        write-host '   '$User.EmployeeID
        $query  = "SELECT CPF FROM VA_VFUNCIONARIOS WHERE CONTRATO = '" +$User.EmployeeID.Substring(10, $User.EmployeeID.Length - 10) + "'"
        write-host '   '$query
        $cmd = new-object System.Data.SqlClient.SqlCommand($query, $connection);
        $reader = $cmd.ExecuteReader()
        if ($reader.Read())
        {
            write-host '   CPF:'$reader.GetValue(0)
            set-aduser $User -EmployeeID $reader.GetValue(0)
        }
        $reader.Close()
    }
}
#>

<# Esqueci de colocar 'CPF' antes do numero
$Users = @(get-aduser -Filter * -properties EmployeeID)
foreach ($User in $Users)
{
    if ($User.EmployeeID.Length -eq 11) # -and $User.SamAccountName -eq 'robert.koch')
    {
        $CPF = 'CPF '+$User.EmployeeID
        write-host $CPF
        set-aduser $User -EmployeeID $CPF
    }
}
#>
