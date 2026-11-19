# Instala la skill "equipo" para el usuario actual.
# Uso: .\instalar.ps1

$ErrorActionPreference = 'Stop'

$origen  = $PSScriptRoot
$destino = Join-Path $env:USERPROFILE ".claude\skills\equipo"
$archivos = @('SKILL.md', 'instalar.md')

foreach ($a in $archivos) {
    if (-not (Test-Path (Join-Path $origen $a))) {
        Write-Host "Falta $a en $origen. Corre el script desde la carpeta equipo-skill." -ForegroundColor Red
        exit 1
    }
}

if (-not (Test-Path $destino)) {
    New-Item -ItemType Directory -Force $destino | Out-Null
}

foreach ($a in $archivos) {
    Copy-Item (Join-Path $origen $a) $destino -Force
    Write-Host "  $a" -ForegroundColor Green
}

Write-Host ""
Write-Host "Instalada en: $destino"
Write-Host "Abre una sesion nueva de Claude Code y escribe /equipo"
Write-Host ""
Write-Host "Si tu plan no da Opus a subagentes, baja el model: de arquitecto a sonnet"
Write-Host "en .claude\agents\arquitecto.md despues del primer montaje."
