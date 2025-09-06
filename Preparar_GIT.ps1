$Host.UI.RawUI.BackgroundColor = 'Black'
$Host.UI.RawUI.ForegroundColor = 'White'
Clear-Host

function Script-Logo {
    Write-Host ""
    Write-Host "===================================================================================" -ForegroundColor White
    Write-Host " ███╗  ███╗    ██████╗             ██████╗   █████╗  ███╗   ███╗ ███████╗ ██████╗" -ForegroundColor Red
    Write-Host " ══██╗ ══██╗   ██╔══██╗           ██╔════╝  ██╔══██╗ ████╗ ████║ ██╔════╝ ██╔══██╗" -ForegroundColor Red
    Write-Host "    ██╗   ██╗  ██║  ██║           ██║  ███╗ ███████║ ██╔████╔██║ █████╗   ██████╔╝" -ForegroundColor Red
    Write-Host "   ██╔╝  ██╔╝  ██╚══██║           ██║   ██║ ██╔══██║ ██║╚██╔╝██║ ██╔══╝   ██╔══██╗" -ForegroundColor Red
    Write-Host " ███╔╝ ███╔╝   ██████╔╝  ███╗     ╚██████╔╝ ██║  ██║ ██║ ╚═╝ ██║ ███████╗ ██║  ██║" -ForegroundColor Red
    Write-Host " ═══╝  ═══╝    ╚═════╝   ╚══╝      ╚═════╝  ╚═╝  ╚═╝ ╚═╝     ╚═╝ ╚══════╝ ╚═╝  ╚═╝" -ForegroundColor Red
    Write-Host "===================================================================================" -ForegroundColor White
    Write-Host ""
}

Script-Logo
function Test-Admin {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    return (New-Object Security.Principal.WindowsPrincipal($user)).IsInRole($adminRole)
}

if (-not (Test-Admin)) {
    Write-Warning "Este script requiere permisos elevados. Reiniciando como administrador..."
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    Exit
}
cls
Script-Logo

Read-Host @"
 PREPARACIÓN .ISO PARA INSTALACIÓN LOCAL

 Si necesitas realizar la instalación de un Windows en un equipo, pero no tenemos
 disponible una unidad externa, ya sea USB, HDD o DVD, entonces esta utilidad te
 ayudara en la prepararación una imágen en formato .ISO de Windows a un instalador
 configurado en una partición booteable de la unidad principal.

 Es indispensable seguir las instrucciones mostradas para un buen desarrollo.

 REQUISITOS:

 - Imagen Windows en formato únicamente .ISO de Win7, Win8, Win8.1, Win10,
   Win11 o WinServerXXXX.
 - Espacio libre de 7.2GB en la partición donde tienes tu actual Windows
   instalado y en ejecución.

 Al finalizar este asistente, se entregarán instrucciones para iniciar la
 instalación de Windows.

 Presiona Enter para comenzar...
"@
Start-Sleep -Seconds 2
cls
Script-Logo

$bootPartition = Get-Partition | Where-Object { $_.IsBoot -eq $true }
if ($bootPartition) {
    Write-Host "✅ Partición de arranque detectada correctamente." -ForegroundColor Green
} else {
    Write-Host "❌ No se encontró una partición de arranque." -ForegroundColor Red
    Read-Host "`nPresiona ENTER para cerrar"
    Exit
}
Start-Sleep -Seconds 2
cls
Script-Logo

$shrinkSize = 7GB
try {
    Resize-Partition -PartitionNumber $bootPartition.PartitionNumber -DiskNumber $bootPartition.DiskNumber -Size ($bootPartition.Size - $shrinkSize)
    Write-Host "✅ Partición reducida correctamente en 7GB." -ForegroundColor Green
} catch {
    Write-Host "❌ Error al reducir la partición. $_" -ForegroundColor Red
    Read-Host "`nPresiona ENTER para cerrar"
    Exit
}
Start-Sleep -Seconds 2
cls
Script-Logo

try {
    $disk = Get-Disk -Number $bootPartition.DiskNumber
    $newPartition = New-Partition -DiskNumber $disk.Number -UseMaximumSize -AssignDriveLetter
    Format-Volume -Partition $newPartition -FileSystem NTFS -NewFileSystemLabel "Win_Install" -Confirm:$false
    Write-Host "✅ Nueva partición 'Win_Install' creada y formateada correctamente." -ForegroundColor Green
} catch {
    Write-Host "❌ Error al crear la nueva partición. $_" -ForegroundColor Red
    Read-Host "`nPresiona ENTER para cerrar"
    Exit
}
Start-Sleep -Seconds 2
cls
Script-Logo

$newLetter = (Get-Volume -FileSystemLabel "Win_Install").DriveLetter
Write-Host "✅ Letra de la nueva unidad obtenida."
Start-Sleep -Seconds 2
cls
Script-Logo

Write-Host "`n📂 Por favor ubica y selecciona un archivo .ISO de Windows válido" -ForegroundColor Cyan
Add-Type -AssemblyName System.Windows.Forms
$OpenISO = New-Object System.Windows.Forms.OpenFileDialog
$OpenISO.Filter = "ISO files (*.iso)|*.iso"
$OpenISO.Title = "Selecciona archivo ISO"
$OpenISO.ShowDialog() | Out-Null
$isoPath = $OpenISO.FileName

if (-not $isoPath) {
    Write-Warning "No se seleccionó ningún archivo ISO."
    Read-Host "`nPresiona ENTER para cerrar"
    Exit
}

try {
    Mount-DiskImage -ImagePath $isoPath -StorageType ISO -PassThru | Out-Null
    Start-Sleep -Seconds 2
    $mountedVolumes = Get-Volume | Where-Object { $_.FileSystemLabel -eq "CDROM" -or $_.DriveType -eq 'CD-ROM' }
    $mountDriveLetter = ($mountedVolumes | Where-Object { Test-Path "$($_.DriveLetter):\" }).DriveLetter
    if (-not $mountDriveLetter) {
        throw "No se pudo identificar la letra de la unidad montada."
    }
    Write-Host "✅ Imagen cargada correctamente desde el archivo ISO." -ForegroundColor Green
} catch {
    Write-Host "❌ Error al montar la imagen ISO. $_" -ForegroundColor Red
    Read-Host "`nPresiona ENTER para cerrar"
    Exit
}
Start-Sleep -Seconds 2
cls
Script-Logo

$sourcePath = "$mountDriveLetter`:\" 
$destinationPath = "${newLetter}`:\" 
$files = Get-ChildItem -Path $sourcePath -Recurse -File
$totalFiles = $files.Count
$copiados = 0
$fallidos = 0

if ($totalFiles -eq 0) {
    Write-Warning "La imagen ISO no contiene archivos válidos."
    Read-Host "`nPresiona ENTER para cerrar"
    Exit
}

foreach ($file in $files) {
    $relativePath = $file.FullName.Substring($sourcePath.Length)
    $targetFile = Join-Path $destinationPath $relativePath
    $targetFolder = Split-Path $targetFile

    if ($targetFolder -and ($targetFolder -match '^[a-zA-Z]:\\')) {
        if (!(Test-Path $targetFolder)) {
            try {
                New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null
            } catch {
                Write-Warning "❌ No se pudo crear carpeta: $targetFolder"
                $fallidos++
                continue
            }
        }
    } else {
        Write-Warning "⚠️ Ruta no válida para crear carpeta: $targetFolder"
        $fallidos++
        continue
    }

    try {
        Copy-Item -Path $file.FullName -Destination $targetFile -Force -ErrorAction Stop
        $copiados++
    } catch {
        $fallidos++
    }

    $progress = [math]::Round(($copiados + $fallidos) / $totalFiles * 100)
    Write-Progress -Activity "Copiando archivos..." -Status "$progress% completado" -PercentComplete $progress
}

Write-Progress -Activity "Copiando archivos..." -Completed
Start-Sleep -Seconds 2
cls
Script-Logo

$destFiles = Get-ChildItem -Path $destinationPath -Recurse -File
$copiadosFinal = $destFiles.Count

if ($copiadosFinal -eq $totalFiles) {
    Write-Host "✅ Verificación exitosa: todos los archivos fueron copiados correctamente." -ForegroundColor Green
    Dismount-DiskImage -ImagePath $isoPath
} else {
        $faltantes = $totalFiles - $copiadosFinal
    Write-Host "❌ Verificación fallida: faltan $faltantes archivos en el destino." -ForegroundColor Red
    Write-Host "La imagen montada **no** será desmontada para que puedas revisar manualmente." -ForegroundColor Yellow
    Read-Host "`nPresiona ENTER para cerrar o revisar manualmente"
    Exit
}
Start-Sleep -Seconds 2
cls
Script-Logo

Read-Host @"
 PREPARACIÓN .ISO PARA INSTALACIÓN LOCAL

 El proceso de preparación ha terminado satisfactoriamente.

 El equipo ahora se reiniciará e ingresará al MENÚ DE OPCIONES AVANZADAS DE
 INICIO (Pantalla azul).

 Pasos a seguir:
 - Navega a las opciones de solución de problemas, luego a opciones avanzadas y 
   finalmente selecciona 'Símbolo del sistema'.
 - Al iniciar CMD, escribe: DISKPART
 - Luego escribe: LIST VOLUME
 - Memoriza la letra de la partición Win_Install
 - Escribe: EXIT
 - En CMD, escribe la letra memorizada seguida de dos puntos (ej: F:) y presiona Enter
 - Finalmente, escribe: setup.exe y presiona Enter

 En este punto se iniciará la instalación de Windows como siempre.
 En la sección de particiones, elimina lo que desees salvo la partición Win_Install
 y continúa con el proceso.

 DISFRUTA DE TU NUEVO WINDOWS!!!

 Presiona Enter para reiniciar el equipo e ingresar al MENÚ DE OPCIONES AVANZADAS
 DE INICIO (Pantalla azul)...
"@
Start-Sleep -Seconds 2
cls
Script-Logo

Read-Host
shutdown /r /o /t 3