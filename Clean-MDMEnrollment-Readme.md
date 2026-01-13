# MDM Enrollment Cleanup Script

**Script Name:** `Clean-MDMEnrollment.ps1`

This PowerShell script performs a comprehensive "nuke and pave" of local Mobile Device Management (MDM) and Microsoft Intune enrollment artifacts. 

**Key Use Case:** This script resolves 99% of issues where the device is successfully Entra ID (Azure AD) or Hybrid Joined, but the subsequent enrollment into Intune hangs or fails.

## Capabilities

This script automates the manual cleanup process by performing the following actions:

1.  **Service Management:** Stops the **dmwappushservice** (WAP Push Message Routing Service) to release file locks.
2.  **Registry Cleanup:** Recursively deletes enrollment keys from:
    * `HKLM:\SOFTWARE\Microsoft\Enrollments`
    * `HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked`
    * `HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled`
    * `HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers`
3.  **Task Cleanup:** Removes all scheduled tasks and folders located under `\Microsoft\Windows\EnterpriseMgmt`.
4.  **Certificate Cleanup:** Scans the **Local Machine\My** store and removes certificates issued by "Intune" or "MDM".
5.  **Logging:** Generates a detailed transcript of all actions.

## Prerequisites

* **OS:** Windows 10 or Windows 11
* **Permissions:** Must be executed in an **Administrator** PowerShell session.

## Usage

1.  Download `Clean-MDMEnrollment.ps1` to the target device.
2.  Open PowerShell as Administrator.
3.  Execute the script:
    ```powershell
    .\Clean-MDMEnrollment.ps1
    ```
4.  **Reboot:** After execution, you must restart the computer (or sign out and back in) to clear any cached handles before attempting re-enrollment.

## Logging

The script automatically creates a log folder and file for audit purposes:
* **Location:** `C:\Temp\`
* **Filename Format:** `MDM-Cleanup-Log_yyyy-MM-dd_HH-mm-ss.log`

## Important Notes

* **Execution Policy:** For security hygiene, the script sets the PowerShell Execution Policy to `Restricted` immediately upon completion.
* **Destructive Action:** This is a remediation tool, not a management tool. Running this on a healthy device will sever its connection to Intune and stop it from receiving policy updates until it is manually re-enrolled.

## Disclaimer
This script is provided as-is for incident response and troubleshooting. Always test in a non-production environment before broad deployment.
