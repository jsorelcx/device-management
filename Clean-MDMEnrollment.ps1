# --- 1. Setup Logging ---
$logFolder = "C:\Temp"
if (-not (Test-Path -Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
}
$logFile = Join-Path -Path $logFolder -ChildPath "MDM-Cleanup-Log_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"

# Custom logging function to write to both console and file
function Write-Log {
    param(
        [string]$Message
    )
    $timestampedMessage = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] - $Message"
    Write-Host $timestampedMessage
    Add-Content -Path $logFile -Value $timestampedMessage
}

Write-Log "MDM Cleanup Script Started. Log file will be saved to: $logFile"

# --- 2. Stop the Device Management Service ---
Write-Log "Attempting to stop the Device Management service (dmwappushservice)..."
try {
    Stop-Service -Name "dmwappushservice" -Force -ErrorAction Stop
    Write-Log "Service 'dmwappushservice' stopped successfully."
}
catch {
    Write-Log "Service 'dmwappushservice' was not running or could not be stopped. This is usually okay."
}

# --- 3. Registry Cleanup ---
Write-Log "Starting Registry Cleanup..."
$enrollmentPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Enrollments",
    "HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked",
    "HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled",
    "HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers"
)

foreach ($path in $enrollmentPaths) {
    if (Test-Path $path) {
        Write-Log "Path found: $path. Deleting all subkeys..."
        Get-ChildItem -Path $path | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Successfully cleared keys under: $path"
    } else {
        Write-Log "Path not found, skipping: $path"
    }
}
Write-Log "Registry Cleanup finished."

# --- 4. Scheduled Task Cleanup ---
Write-Log "Starting Scheduled Task Cleanup..."
$taskPath = "\Microsoft\Windows\EnterpriseMgmt"
$tasks = Get-ScheduledTask -TaskPath $taskPath -ErrorAction SilentlyContinue

if ($tasks.Count -gt 0) {
    Write-Log "Found $($tasks.Count) tasks/folders under $taskPath."
    foreach ($task in $tasks) {
        $guidPath = $task.TaskPath
        if ($guidPath -ne $taskPath) {
            Write-Log "Attempting to remove task folder: $guidPath"
            try {
                Unregister-ScheduledTask -TaskPath "$guidPath\*" -Confirm:$false -ErrorAction Stop
                Invoke-Expression "schtasks.exe /delete /tn `"$guidPath\`" /f"
                Write-Log "Successfully removed task folder: $guidPath"
            }
            catch {
                Write-Log "Could not remove task folder: $guidPath. It may have been removed by a previous step."
            }
        }
    }
} else {
    Write-Log "No scheduled tasks found under $taskPath to clean up."
}
Write-Log "Scheduled Task Cleanup finished."

# --- 5. Certificate Cleanup ---
Write-Log "Starting Certificate Cleanup..."
$certStore = "cert:\LocalMachine\My"
$mdmCerts = Get-ChildItem -Path $certStore | Where-Object { $_.Issuer -like "*Intune*" -or $_.Issuer -like "*MDM*" }

if ($mdmCerts.Count -gt 0) {
    Write-Log "Found $($mdmCerts.Count) MDM-related certificates to remove."
    foreach ($cert in $mdmCerts) {
        Write-Log "Removing certificate with Thumbprint: $($cert.Thumbprint)"
        Remove-Item -Path "$certStore\$($cert.Thumbprint)" -Force
    }
} else {
    Write-Log "No MDM certificates found in the machine store."
}
Write-Log "Certificate Cleanup finished."

Set-ExecutionPolicy restricted -force

Write-Log "Restored Exectution Policy"

# --- 6. Final Instructions ---
Write-Log "--------------------------------------------------------" -ForegroundColor Green
Write-Log "SCRIPT EXECUTION COMPLETE." -ForegroundColor Green
Write-Log "Please have the end-user sign out and sign back in to trigger re-enrollment." -ForegroundColor Green
Write-Log "--------------------------------------------------------" -ForegroundColor Green
