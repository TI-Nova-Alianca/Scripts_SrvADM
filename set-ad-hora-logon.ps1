Import-Module ActiveDirectory -ErrorAction SilentlyContinue
[array]$horaLogon = (Get-ADUser reila.capp -Properties logonHours).logonHours
Get-ADUser -Identity foliveira.capp | Set-ADUser -add @{logonhours=$horaLogon} 



#http://www.bosontreinamentos.com.br/windows-powershell/configurar-horario-de-logon-no-active-directory-via-powershell/
# https://richardspowershellblog.wordpress.com/2012/01/26/setting-a-users-logon-hours/
#https://social.technet.microsoft.com/Forums/pt-BR/75cab08d-6856-4d57-b18c-fc66d5092d7d/log-on-de-usurios-por-horrio-gpo?forum=winsrv2008pt