# usuarios.ps1
$usuarios = Import-Csv empleados.csv

foreach ($usuario in $usuarios) {
    $nombre = $usuario.Nombre
    $correo = $usuario.Correo
    $username = $correo.Split("@")[0]
    $password = [System.Web.Security.Membership]::GeneratePassword(12, 3)
    
    Try {
        New-LocalUser -Name $username -FullName $nombre -Password (ConvertTo-SecureString $password -AsPlainText -Force) -PasswordNeverExpires:$true
        Add-LocalGroupMember -Group "Administrators" -Member $username
        "$($username),$($nombre),exitoso,$((Get-Date))" | Out-File -Append logs/log_usuarios.log
    } Catch {
        "$($username),$($nombre),fallido,$((Get-Date))" | Out-File -Append logs/log_usuarios.log
    }
}
