# Check if the script is running with administrator privilege
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}

$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$entry = "127.0.0.1 www.facebook.com"

# Ensure the hosts file is writable (removes read-only attribute if set)
if ((Get-Item $hostsPath).IsReadOnly) {
    Set-ItemProperty -Path $hostsPath -Name IsReadOnly -Value $false
}

# Display a prompt window
Add-Type -AssemblyName Microsoft.VisualBasic
$choice = [Microsoft.VisualBasic.Interaction]::InputBox("Enter 'A' to add the entry or 'R' to remove it.", "Hosts File Editor", "")

switch ($choice.ToLower()) {
    "a" {
        # Read all lines and check if the entry exists
        $content = Get-Content $hostsPath
        if ($content -contains $entry) {
            Write-Host "Entry already exists."
        } else {
            Add-Content -Path $hostsPath -Value "`r`n$entry"
            Write-Host "Entry added successfully."
        }
    }
    "r" {
        # Read all lines, filter out the entry, and rewrite the file safely
        $content = Get-Content -Path $hostsPath
        $filteredContent = $content | Where-Object { $_ -ne $entry }

        if ($content.Count -eq $filteredContent.Count) {
            Write-Host "Entry was not found in the hosts file."
        } else {
            # Forcefully unlock the file if necessary
            $tempFile = "$env:TEMP\hosts_temp"
            $filteredContent | Out-File -FilePath $tempFile -Encoding utf8
            Move-Item -Path $tempFile -Destination $hostsPath -Force
            Write-Host "Entry removed successfully."
        }
    }
    default {
        Write-Host "Invalid input. Please enter 'A' to add or 'R' to remove."
    }
}

pause