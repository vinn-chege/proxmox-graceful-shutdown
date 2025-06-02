# Battery Shutdown Monitor Service

This repository contains a script that sets up a service to monitor the battery level on a Proxmox server and perform a graceful shutdown if the battery level falls below 10% and AC power is not connected.

## Installation

You can easily install and configure the script using `curl`. Run the following command to download and execute the setup script:

```bash
curl -fsSL https://raw.githubusercontent.com/vinn-chege/proxmox-graceful-shutdown/main/setup_battery_shutdown.sh | sudo bash
```
