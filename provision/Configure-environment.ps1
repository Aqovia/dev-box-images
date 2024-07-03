function CreateSymlink {
    param (
        [string]$target,
        [string]$link
    )

    if (-not (Test-Path -Path $target)) {
        New-Item -ItemType Directory -Path $target | Out-Null
    }

    $isReparsePoint = fsutil reparsepoint query $target 2>&1
    if ($LASTEXITCODE -eq 1) {
        Write-Host "Turning '$target' into a link to '$link' to make the 'profile backup' functionality happy."
        Move-Item -Path $target -Destination $link
        cmd /c mklink /J $target $link
    }
}

# Move npm folder
CreateSymlink "$env:APPDATA\npm" "$env:LOCALAPPDATA\npm"

# Move npm-cache folder
CreateSymlink "$env:APPDATA\npm-cache" "$env:LOCALAPPDATA\npm-cache"

# Move .nuget\packages folder
CreateSymlink "$env:USERPROFILE\.nuget\packages" "$env:LOCALAPPDATA\NuGet\packages"

# Move .vscode folder
CreateSymlink "$env:USERPROFILE\.vscode" "$env:LOCALAPPDATA\vscode"

# Listing installed .NET Frameworks
Write-Host "Listing installed .NET Frameworks: "
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name Version, Release -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match '^(?!S)\p{L}'} | Select-Object PSChildName, Version, Release

# Set kubernetes configuration environment variable
[Environment]::SetEnvironmentVariable('KUBECONFIG', "$env:HOME\.kube\config", [EnvironmentVariableTarget]::Machine)

# Set development Inventory and SalesforcePartial databases' environment variables
[Environment]::SetEnvironmentVariable('Dev_InventoryDB_Server', 'nl-ams-ptldb-a1', [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('Dev_SalesforcePartialDB_Server', 'nl-ams-ptldb-a1', [EnvironmentVariableTarget]::Machine)

# Set Azure tenant environment variable
[Environment]::SetEnvironmentVariable('AZURE_TENANT_ID', '5226521a-cae0-4a6b-a04b-3ba17e7ac24f', [EnvironmentVariableTarget]::Machine)

# Set ASPNETCORE_ENVIRONMENT environment variable to Development
[Environment]::SetEnvironmentVariable('ASPNETCORE_ENVIRONMENT', 'Development', [EnvironmentVariableTarget]::Machine)

# End of the script
Write-Host "Script completed."
