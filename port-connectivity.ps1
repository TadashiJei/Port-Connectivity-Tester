# Function to show a colorful banner
function Show-Banner {
    Write-Host "`n=========================================" -ForegroundColor Cyan
    Write-Host "   Enhanced Port Connectivity Tester" -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan
}

# Function to get user input for servers
function Get-ServerList {
    $serverList = @()
    do {
        $server = Read-Host "Enter a server name (or press Enter to finish)"
        if ($server -ne "") {
            $serverList += $server
        }
    } while ($server -ne "" -and $serverList.Count -lt 20)
    return $serverList
}

# Function to display the menu and get user selection
function Get-PortSelection {
    $ports = @{
        1 = @{Name = "HTTP"; Port = 80}
        2 = @{Name = "HTTPS"; Port = 443}
        3 = @{Name = "FTP"; Port = 21}
        4 = @{Name = "SSH"; Port = 22}
        5 = @{Name = "Telnet"; Port = 23}
        6 = @{Name = "SMTP"; Port = 25}
        7 = @{Name = "DNS"; Port = 53}
        8 = @{Name = "WinRM"; Port = 5985}
        9 = @{Name = "Custom"; Port = 0}
    }

    Write-Host "`nSelect a port to test:" -ForegroundColor Yellow
    foreach ($key in $ports.Keys | Sort-Object) {
        Write-Host "$key. $($ports[$key].Name) (Port $($ports[$key].Port))"
    }

    do {
        $selection = Read-Host "`nEnter your selection"
        if ($selection -eq "9") {
            $customPort = Read-Host "Enter the custom port number"
            return [int]$customPort
        }
    } while ($selection -notin $ports.Keys)

    return $ports[$selection].Port
}

# Function to test port connectivity
function Test-PortConnectivity {
    param (
        [string]$server,
        [int]$port
    )
    
    $result = Test-NetConnection -ComputerName $server -Port $port -InformationLevel Detailed -WarningAction SilentlyContinue

    $status = if ($result.TcpTestSucceeded) { "Success" } else { "Failed" }
    
    [PSCustomObject]@{
        Server = $server
        Port = $port
        Status = $status
        RemoteAddress = $result.RemoteAddress.IPAddressToString
        PingSucceeded = $result.PingSucceeded
        NameResolutionSucceeded = $result.NameResolutionSucceeded
        ResponseTime = if ($result.PingSucceeded) { "$($result.PingReplyDetails.RoundtripTime) ms" } else { "N/A" }
    }
}

# Main script
Show-Banner

$servers = Get-ServerList
$port = Get-PortSelection

Write-Host "`nTesting port connectivity..." -ForegroundColor Yellow

$results = foreach ($server in $servers) {
    Test-PortConnectivity -server $server -port $port
}

# Display results in a formatted table with colors
Write-Host "`nPort Connectivity Test Results:" -ForegroundColor Green
$results | Format-Table -AutoSize | Out-String | ForEach-Object {
    if ($_ -match "Success") {
        Write-Host $_ -ForegroundColor Green -NoNewline
    } elseif ($_ -match "Failed") {
        Write-Host $_ -ForegroundColor Red -NoNewline
    } else {
        Write-Host $_ -NoNewline
    }
}

# Export results to a CSV file
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$csvPath = "PortConnectivityResults_$timestamp.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "`nResults have been exported to $csvPath" -ForegroundColor Cyan

# Generate an HTML report
$htmlPath = "PortConnectivityReport_$timestamp.html"
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Port Connectivity Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f0f0f0; }
        h1 { color: #333; }
        table { border-collapse: collapse; width: 100%; background-color: white; }
        th, td { text-align: left; padding: 8px; border-bottom: 1px solid #ddd; }
        th { background-color: #4CAF50; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .success { color: green; }
        .failed { color: red; }
    </style>
</head>
<body>
    <h1>Port Connectivity Test Report</h1>
    <p>Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
    <p>Tested Port: $port</p>
    <table>
        <tr>
            <th>Server</th>
            <th>Port</th>
            <th>Status</th>
            <th>Remote Address</th>
            <th>Ping Succeeded</th>
            <th>Name Resolution</th>
            <th>Response Time</th>
        </tr>
        $(foreach ($result in $results) {
            $statusClass = if ($result.Status -eq "Success") { "success" } else { "failed" }
            "<tr>
                <td>$($result.Server)</td>
                <td>$($result.Port)</td>
                <td class='$statusClass'>$($result.Status)</td>
                <td>$($result.RemoteAddress)</td>
                <td>$($result.PingSucceeded)</td>
                <td>$($result.NameResolutionSucceeded)</td>
                <td>$($result.ResponseTime)</td>
            </tr>"
        })
    </table>
</body>
</html>
"@

$htmlContent | Out-File -FilePath $htmlPath
Write-Host "An HTML report has been generated at $htmlPath" -ForegroundColor Cyan

# Open the HTML report
Start-Process $htmlPath
