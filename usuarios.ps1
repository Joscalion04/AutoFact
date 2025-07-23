# usuarios.ps1

# Ruta del CSV (ajustar si es necesario)
$csvPath = ".\empleados.csv"
$logPath = ".\logs\log_usuarios_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Función para generar contraseña segura
function Generar-Password {
    Add-Type -AssemblyName System.Web
    return [System.Web.Security.Membership]::GeneratePassword(12, 3)
}

# Asegurar que exista el directorio de logs
if (!(Test-Path -Path (Split-Path $logPath))) {
    New-Item -ItemType Directory -Path (Split-Path $logPath) -Force | Out-Null
}

# Leer CSV y procesar usuarios
Import-Csv $csvPath | ForEach-Object {
    $nombre = $_.Nombre
    $correo = $_.Correo
    $usuario = ($correo.Split("@"))[0]
    $password = Generar-Password

    try {
        # Crear usuario local
        net user $usuario $password /add /fullname:"$nombre" /comment:"Usuario temporal" /yes

        # Agregar al grupo de administradores
        net localgroup Administrators $usuario /add

        # Log
        $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Usuario '$usuario' creado. Nombre: $nombre, Correo: $correo, Contraseña: $password"
        Add-Content -Path $logPath -Value $logEntry
        Write-Output $logEntry
    } catch {
        $errorEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR al crear usuario '$usuario': $_"
        Add-Content -Path $logPath -Value $errorEntry
        Write-Error $errorEntry
    }
}
