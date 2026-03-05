# WordPress Docker launcher for Windows (PowerShell) — 2026
# Requires: Docker Desktop for Windows, PowerShell 5.1+ or PowerShell Core 7+

param(
    [switch]$Help,
    [switch]$Debug,
    [switch]$Verbose,
    [switch]$Run,
    [switch]$Stop
)

$ErrorActionPreference = "Stop"
$BaseSelf = Split-Path -Leaf $MyInvocation.MyCommand.Path
$WordPressDir = Join-Path (Get-Location) "docker-wordpress"

function Write-Err {
    param([string]$Message)
    Write-Error "Error: $Message"
    exit 1
}

function Show-Usage {
    @"
Usage: $BaseSelf [OPTIONS]

Options:
  -Help        Display this help message.
  -Debug       Enable debug mode.
  -Verbose     Enable verbose output.
  -Run         Run the WordPress Docker Compose.
  -Stop        Stop the WordPress Docker Services.

Examples:
  .\wordpress.ps1 -Run
  .\wordpress.ps1 -Stop
"@
    exit 0
}

function Write-DebugMsg {
    param([string]$Message)
    if ($Debug) { Write-Host "[DEBUG] $Message" }
}

function Open-Browser {
    param([string]$Url = "http://localhost:8080/")
    try {
        Start-Process $Url
        Write-Host "Successfully opened $Url in your web browser."
    } catch {
        Write-Host "Could not open browser. Visit $Url manually."
    }
}

function Start-WordPress {
    Write-DebugMsg "Starting WordPress services..."

    if (-not (Test-Path -LiteralPath $WordPressDir -PathType Container)) {
        Write-Err "Directory not found: $WordPressDir"
    }

    Push-Location $WordPressDir
    try {
        docker compose up -d
        if ($LASTEXITCODE -ne 0) {
            Write-Err "Failed to execute Docker Compose."
        }
        Open-Browser "http://localhost:8080/"
    } finally {
        Pop-Location
    }
}

function Stop-WordPress {
    if (-not (Test-Path -LiteralPath $WordPressDir -PathType Container)) {
        Write-Err "Directory not found: $WordPressDir"
    }

    Push-Location $WordPressDir
    try {
        $running = docker ps -q 2>$null
        if ($running) {
            docker compose down
            if ($LASTEXITCODE -eq 0) {
                Write-Host "WordPress successfully closed!"
            } else {
                Write-Err "WordPress cannot be closed!"
            }
        } else {
            Write-Host "There are no services to close."
        }
    } finally {
        Pop-Location
    }
}

# Validate at least one option if any args given
$valid = $Help -or $Run -or $Stop -or $Verbose -or $Debug
if (-not $valid -and $args.Count -gt 0) {
    Write-Err "Invalid option. Use -Help for usage."
}

if ($Help) { Show-Usage }
if ($Verbose) { Write-Host "Starting Docker Compose in $WordPressDir" }
if ($Run) { Start-WordPress }
if ($Stop) { Stop-WordPress }

if (-not ($Help -or $Run -or $Stop -or $Verbose)) {
    Show-Usage
}
