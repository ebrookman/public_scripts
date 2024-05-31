# elevate.ps1

param (
    [string]$ScriptPath
)

# Check if running as administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Re-run the script with elevated permissions
    $newProcess = Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$ScriptPath`"" -Verb RunAs -PassThru
    $newProcess.WaitForExit()
    exit $newProcess.ExitCode
}

# If already running as administrator, execute the main script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$scriptFullPath = Join-Path -Path $scriptDirectory -ChildPath $ScriptPath
Write-Output "Running script with elevated privileges: $scriptFullPath"
. $scriptFullPath
