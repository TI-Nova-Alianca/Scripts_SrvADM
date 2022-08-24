# Script para (des)bloqueio de usuarios no A.D. com base nos dados do Metadados.
# Os CPFs devem estar informados no campo 'EmployeeId' do cadastro do usuario no A.D. no formato 'CPF xxxxxx'
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
# 13/10/2020 - Robert - Versao inicial considerando horarios de escalas, etc. no Metadados. Apenas gera log para testes.
# 12/11/2020 - Robert - Comeca a bloquear algumas pessoas (RH e TI) para testes.
#                     - Passa a aceitar 'CPF' e 'Pessoa' como chaves no EmployeeID

# dica: https://www.powershellcenter.com/2021/03/09/manage-ad-user-logon-hours-using-powershell/

# Importa arquivos de funcoes via 'dot source' para que as funcoes possam ser usadas aqui.
. C:\util\Scripts\Function_Grava-Log.ps1

# -----------------------------------------------------------------
$QtUsers = 0

Grava-Log('Iniciando execucao')

# lista conteudo atual:  Get-aduser -filter * -Properties employeeid | Select-Object name, employeeid

# Busca matriculas no Matadados. Usa credencial de 'consultas' para conectar ao SQL
$SQLUser = "consultas"
$Password = "consultas" | ConvertTo-SecureString -AsPlainText -Force
$Password.MakeReadOnly()
$cred = New-Object System.Data.SqlClient.SqlCredential($SQLUser,$Password)
$connection = new-object System.Data.SqlClient.SQLConnection("Data Source=SrvMeta;Initial Catalog=SIRH");
$connection.credential = $cred
$connection.Open();
$query  = "SELECT F.CPF, F.NOME, H.ACAO, H.OBSERVACAO, H.INILIBERACAO, H.FIMLIBERACAO, F.PESSOA"
$query +=  " FROM VA_VFUNCIONARIOS F"
$query +=  " CROSS APPLY VA_FVERIFICAHORARIO (F.PESSOA, CURRENT_TIMESTAMP) H"
$query +=  " order by NOME"
#Grava-Log($query)
$cmd = new-object System.Data.SqlClient.SqlCommand($query, $connection);
$reader = $cmd.ExecuteReader()
while ($reader.Read())
{
    $CPF       = $reader.GetValue(0)
    $Nome      = $reader.GetValue(1)
    $Acao      = $reader.GetValue(2)
    $Obs       = $reader.GetValue(3)
    $HoraIni   = $reader.GetValue(4)
    $HoraFim   = $reader.GetValue(5)
    $PessoaRH  = $reader.GetValue(6)
    #$Filtro    = 'CPF ' + $CPF
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
#        write-host $User.SamAccountName

        # Grava log para testes
        Grava-log ($User.SamAccountName.PadRight(20, ' ') + ': ' + $acao + ' (' + $Obs + ') horario para liberacao entre ' + $HoraIni + ' e ' + $HoraFim)

        # Migrando alguns usuarios para este script. Os demais ainda permanecem no anterior.
        if ($User.SamAccountName -eq 'andre.oliveira' -or
            $User.SamAccountName -eq 'claudia.lionco' -or # deu erro...  $User.SamAccountName -eq 'daiana.ribas' -or
            $User.SamAccountName -eq 'sandra.sugari')
        {
            if ($Acao -eq 'B')
            {
                if ($User.Enabled)
                {
                    Grava-log ('Bloqueando ' + $User.SamAccountName.PadRight(20, ' ') + ': ' + $Obs + ') horario para liberacao entre ' + $HoraIni + ' e ' + $HoraFim)
   #                 $User | Disable-ADAccount
                }
            }
            else
            {
                if (-not $User.Enabled)
                {
                    Grava-log ('Desbloqueando ' + $User.SamAccountName.PadRight(20, ' ') + ': ' + $Obs + ') horario para liberacao entre ' + $HoraIni + ' e ' + $HoraFim)
    #                $User | Enable-ADAccount
                }
            }
        }
        $QtUsers ++
    }
}
$reader.Close()
Grava-Log('Finalizando execucao. ' + $QtUsers.ToString() + ' contas verificadas.')
