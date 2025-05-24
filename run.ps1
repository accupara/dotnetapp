param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("build", "run")]
    [string]$Command
)

# Function to check if Windows Remote Debugger is running
function Is-RemoteDebuggerRunning {
    return (Get-Process msvsmon -ErrorAction SilentlyContinue) -ne $null
}

function Start-RemoteDebugger {
    # Paths for both ProgramFiles and ProgramFiles(x86)
    $programFilesPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\Remote Debugger\x64\msvsmon.exe"
    $programFilesPathX86 = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\Common7\IDE\Remote Debugger\x64\msvsmon.exe"
    # Port to run on
    $port = 4026

    #.\msvsmon.exe /nostatus /silent /noauth /anyuser /nosecuritywarn /FallbackLoadRemoteManagedPdbs
    if (Test-Path $programFilesPath) {
        Write-Host "Starting Windows Remote Debugger..." -ForegroundColor Green
        Start-Process -FilePath $programFilesPath `
                      -ArgumentList "/nostatus /silent /noauth /anyuser /nosecuritywarn /FallbackLoadRemoteManagedPdbs /port:$port" `
                      -WindowStyle Hidden `
                      -RedirectStandardOutput "$env:TEMP\msvsmon.log" `
                      -ErrorAction SilentlyContinue
    } elseif (Test-Path $programFilesPathX86) {
        Write-Host "Starting Windows Remote Debugger..." -ForegroundColor Green
        Start-Process -FilePath $programFilesPathX86 `
                      -ArgumentList "/nostatus /silent /noauth /anyuser /nosecuritywarn /FallbackLoadRemoteManagedPdbs /port:$port" `
                      -WindowStyle Hidden `
                      -RedirectStandardOutput "$env:TEMP\msvsmon.log" `
                      -ErrorAction SilentlyContinue
    } else {
        Write-Warning "Windows Remote Debugger (msvsmon.exe) not found."
    }
}

switch ($Command) {
    "build" {
        Write-Host "Building project in Debug mode..." -ForegroundColor Cyan
        dotnet build --configuration Debug
    }

    "run" {
        Write-Host "Checking for running remote debugger..." -ForegroundColor Cyan

        if (-not (Is-RemoteDebuggerRunning)) {
            Write-Host "Remote Debugger is not running. Starting it now..." -ForegroundColor Yellow
            Start-RemoteDebugger
        } else {
            Write-Host "Remote Debugger is already running." -ForegroundColor Green
        }

        Write-Host "Running application in Debug mode..." -ForegroundColor Cyan
        dotnet run --configuration Debug
    }
}