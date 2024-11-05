# Define the path to the input CSV file and the output file
$inputCsv = "servers.csv"
$outputCsv = "output.csv"

# Read the server names from the CSV file
$servers = Import-Csv -Path $inputCsv

# Initialize an array to hold the results
$results = @()

# Loop through each server and ping it
foreach ($server in $servers) {
    $serverName = $server.ServerName

    try {
        # Try to ping the server once
        $pingResponse = Test-Connection -ComputerName $serverName -Count 1 -ErrorAction Stop

        # Ping succeeded
        $responded = "Yes"

        # Get the IP address from the ping response
        $ipAddress = ($pingResponse | Select-Object -First 1).IPv4Address.IPAddressToString

        # Determine the location based on the IP address
        if ($ipAddress -like "10.7.*") {
            $location = "LVA"
        } elseif ($ipAddress -like "10.9.*") {
            $location = "LVB"
        } else {
            # Extract the second octet to check for AWS range
            $octets = $ipAddress.Split('.')
            if ($octets[0] -eq '10') {
                $secondOctet = [int]$octets[1]
                if ($secondOctet -ge 96 -and $secondOctet -le 144) {
                    $location = "AWS"
                } else {
                    $location = "other"
                }
            } else {
                $location = "other"
            }
        }
    } catch {
        # Ping failed
        $responded = "No"
        $ipAddress = ""
        $location = "other"
    }

    # Create a custom object to store the result
    $result = [PSCustomObject]@{
        ServerName = $serverName
        Responded  = $responded
        IPAddress  = $ipAddress
        Location   = $location
    }

    # Add the result to the array
    $results += $result
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputCsv -NoTypeInformation

# Output a message indicating the script has completed
Write-Host "Ping test completed. Results saved to $outputCsv."
