
---

# Ping Servers with Location Detection

This PowerShell script reads a list of server names from a CSV file, pings each server, and records whether the server responded. If a server responds, the script retrieves its IP address and determines its location based on predefined IP address ranges. The results are saved to an output CSV file.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
  - [Input CSV File Format](#input-csv-file-format)
  - [Running the Script](#running-the-script)
  - [Output CSV File Format](#output-csv-file-format)
- [Script Logic](#script-logic)
  - [Ping Servers](#ping-servers)
  - [Retrieve IP Address](#retrieve-ip-address)
  - [Determine Location](#determine-location)
- [Customization](#customization)
- [Error Handling](#error-handling)
- [License](#license)

## Prerequisites

- Windows PowerShell 5.0 or later.
- Ability to run PowerShell scripts on your system.
- Network access to the servers you wish to ping.

## Installation

1. **Clone or Download the Repository:**

   - Clone the repository using Git:
     ```bash
     git clone https://github.com/darindeters/pingauditor.git
     ```
   - Or download the ZIP file and extract it to your desired location.

2. **Navigate to the Script Directory:**

   Open PowerShell and navigate to the directory containing the script and the input CSV file:
   ```powershell
   cd path\to\your\script\directory
   ```

## Usage

### Input CSV File Format

Prepare an input CSV file named `servers.csv` in the script directory. The CSV file should have a header named `ServerName` and list all the server names or IP addresses you wish to ping.

**Example `servers.csv`:**
```csv
ServerName
server1.domain.com
server2.domain.com
192.168.1.10
```

### Running the Script

1. **Execute the Script:**

   Run the script by typing:
   ```powershell
   .\PingServersWithLocation.ps1
   ```

2. **Script Output:**

   After running the script, you will see a message indicating completion:
   ```
   Ping test completed. Results saved to output.csv.
   ```

### Output CSV File Format

The script generates an output CSV file named `output.csv` containing the following columns:

- `ServerName`: The name or IP address of the server.
- `Responded`: Indicates whether the server responded to the ping (`Yes` or `No`).
- `IPAddress`: The IP address of the server (empty if no response).
- `Location`: The determined location based on the IP address (`LVA`, `LVB`, `AWS`, or `other`).

**Example `output.csv`:**
```csv
"ServerName","Responded","IPAddress","Location"
"server1.domain.com","Yes","10.7.15.20","LVA"
"server2.domain.com","No","","other"
"192.168.1.10","Yes","10.96.34.56","AWS"
```

## Script Logic

### Ping Servers

- The script reads server names from `servers.csv`.
- It pings each server once using the `Test-Connection` cmdlet.
- Ping attempts use `try-catch` blocks to handle any failures.

### Retrieve IP Address

- If the ping is successful, the script extracts the IPv4 address from the ping response.
- If the server does not respond, the IP address field is left empty.

### Determine Location

- The script determines the location based on the IP address:
  - **LVA**: IP addresses starting with `10.7`.
  - **LVB**: IP addresses starting with `10.9`.
  - **AWS**: IP addresses where the second octet is between `96` and `144` (inclusive) and the first octet is `10`.
  - **other**: Any IP addresses outside the specified ranges or if the server did not respond.

**Logic Breakdown:**

```powershell
if ($ipAddress -like "10.7.*") {
    $location = "LVA"
} elseif ($ipAddress -like "10.9.*") {
    $location = "LVB"
} else {
    # Split IP into octets
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
```

## Customization

- **Input and Output File Paths:**

  Modify the `$inputCsv` and `$outputCsv` variables at the top of the script to change the file paths:
  ```powershell
  $inputCsv = "path\to\your\servers.csv"
  $outputCsv = "path\to\your\output.csv"
  ```

- **IP Address Ranges and Locations:**

  Adjust the IP range conditions and location labels in the script to match your network environment.

- **Ping Count:**

  Change the `-Count` parameter in `Test-Connection` to increase the number of ping attempts:
  ```powershell
  $pingResponse = Test-Connection -ComputerName $serverName -Count 3 -ErrorAction Stop
  ```

## Error Handling

- **Ping Failures:**

  The script uses `try-catch` blocks to handle exceptions when a ping fails. Failed pings are recorded with `Responded` set to `No`, and `IPAddress` left empty.

- **Script Execution Policy:**

  If you encounter an error related to script execution policies, consult your system administrator or refer to PowerShell documentation on how to adjust execution policies.

- **Network Connectivity:**

  Ensure you have network access to the servers you wish to ping.

## License

This project is licensed under the MIT License.

---

*Created by Your Darin Deters. Feel free to contribute or report issues.*

---

