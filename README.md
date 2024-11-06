# Port Connectivity Tester

A powerful PowerShell-based tool for testing port connectivity across multiple servers with detailed reporting capabilities.

## Features

- Test connectivity for up to 20 servers simultaneously
- Support for common ports (HTTP, HTTPS, FTP, SSH, etc.)
- Custom port testing capability
- Comprehensive reporting in multiple formats:
  - Console output with color coding
  - CSV export for data analysis
  - HTML report with visual styling
- Response time measurements
- Ping and DNS resolution testing

## Prerequisites

- Windows PowerShell 5.1 or later
- Administrator privileges (for certain port tests)

## Installation

1. Clone or download this repository
2. Ensure both script files are in the same directory:
   - `Test-PortConnectivity.ps1`
   - `RunPortTest.bat`

## Usage

1. Double-click `RunPortTest.bat` to start the application
2. Follow the interactive prompts:
   - Enter server names (up to 20)
   - Select a port to test from the menu or enter a custom port
3. View results in:
   - Console window (real-time)
   - Generated CSV file
   - Interactive HTML report (opens automatically)

## Common Ports Reference

| Service | Port |
|---------|------|
| HTTP    | 80   |
| HTTPS   | 443  |
| FTP     | 21   |
| SSH     | 22   |
| Telnet  | 23   |
| SMTP    | 25   |
| DNS     | 53   |
| WinRM   | 5985 |

## Example Output

```powershell
========================================
   Enhanced Port Connectivity Tester
========================================

Testing Results:
Server               Port    Status    Response Time
--------------------------------------------
server1.example.com  80      Success   15ms
server2.example.com  80      Failed    N/A
