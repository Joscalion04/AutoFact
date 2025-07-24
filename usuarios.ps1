# usuarios.ps1
$csvPath = ".\empleados.csv"
$fecha = Get-Date -Format 'yyyyMMdd_HHmmss'
$logDir = ".\logs"
$logPath = "$logDir\log_usuarios_$fecha.log"

if (!(Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Generar-Password {
    Add-Type -AssemblyName System.Web
    return [System.Web.Security.Membership]::GeneratePassword(12, 3)
}

# Detectar grupo administrador local (toma el primero que contenga 'admin', case-insensitive)
$grupoAdmin = (Get-LocalGroup | Where-Object { $_.Name -match '(?i)admin' } | Select-Object -First 1).Name

if (-not $grupoAdmin) {
    Write-Error "No se encontró ningún grupo administrador local en este sistema."
    exit
}

Import-Csv -Path $csvPath | ForEach-Object {
    $nombre = $_.Nombre
    $correo = $_.Correo

    # Limpiar nombre de usuario: caracteres válidos y evitar dobles puntos
    $usuario = ($correo.Split("@")[0] -replace '[^\w.]', '')
    $usuario = $usuario -replace '\.{2,}', '.'

    # Truncar usuario a 20 caracteres máximo
    if ($usuario.Length -gt 20) {
        $usuario = $usuario.Substring(0,20)
    }

    $password = Generar-Password

    try {
        if (Get-LocalUser -Name $usuario -ErrorAction SilentlyContinue) {
            $mensaje = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - El usuario '$usuario' ya existe. Se omitió la creación."
            Add-Content -Path $logPath -Value $mensaje
            Write-Warning $mensaje
            return
        }

        # Crear usuario local
        New-LocalUser -Name $usuario -Password (ConvertTo-SecureString $password -AsPlainText -Force) `
                      -FullName $nombre -Description "Usuario temporal" -UserMayNotChangePassword:$false `
                      -PasswordNeverExpires:$false

        # Agregar usuario al grupo administrador detectado (string único)
        Add-LocalGroupMember -Group $grupoAdmin -Member $usuario

        # Log
        $log = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Usuario creado: $usuario | Nombre: $nombre | Correo: $correo | Contraseña: $password"
        Add-Content -Path $logPath -Value $log
        Write-Output $log

    } catch {
        $mensajeError = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR al crear '$usuario': $_"
        Add-Content -Path $logPath -Value $mensajeError
        Write-Error $mensajeError
    }
}
