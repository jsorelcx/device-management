# Device Management Toolkit

A collection of PowerShell scripts and utilities for managing, troubleshooting, and remediating Windows devices in Microsoft Endpoint Manager (Intune) and Entra ID environments.

## Repository Contents

### 1. Remediation & Cleanup
* **Script:** [`Clean-MDMEnrollment.ps1`](Clean-MDMEnrollment.ps1)
* **Purpose:** Performs a destructive cleanup of local MDM resources.
* **Best For:** resolving "hanging" enrollments where a device is successfully Entra/Hybrid joined but fails to sync with Intune.
* **Documentation:** [View script documentation](Clean-MDMEnrollment-ReadMe.md)

*(More tools to be added)*

## Getting Started

### Prerequisites
Most scripts in this repository perform administrative actions on the local device or interact with the Microsoft Graph API.

* **Permissions:** Scripts generally require **Local Administrator** privileges.
* **Execution Policy:** Ensure your PowerShell execution policy allows for script execution (e.g., `RemoteSigned` or `Bypass` for the specific process).

### Usage

1. Clone the repository:
   ```bash
   git clone [https://github.com/your-org/device-management.git](https://github.com/your-org/device-management.git)
   ```
2. Navigate to the relevant script.
3. Review the specific header or README for that tool before deployment.

## Roadmap
Future additions to this repository will include:
* Device compliance reporting tools.
* Policy conflict analyzers.
* Bulk action utilities.

## Disclaimer
These tools are provided "as-is" for troubleshooting and management purposes. **Always test** in a non-production environment before deploying to end-user devices.

## License
Licensed under GPL-3.0. See [LICENSE](LICENSE) for full details.
