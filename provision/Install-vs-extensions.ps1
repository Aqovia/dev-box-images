Function Get-VisualStudioExtensionDownloadLink($ExtensionName) {
    $url = "https://marketplace.visualstudio.com/items?itemName=$ExtensionName"
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing
    $downloadUrl = $response.Links | Where-Object { $_.class -eq "install-button-container" } | Select-Object -Expand href

    if ($downloadUrl.startsWith("/") -eq $true) {
        $downloadUrl = "https://marketplace.visualstudio.com$downloadUrl"
    }

    return $downloadUrl
}

Function Install-VisualStudio2022ExtensionByUrl($ExtensionName, $DownloadUrl) {
    $version = $DownloadUrl.Split("/")[-2]
    $vsixPath = "$env:TEMP\$ExtensionName-$version.vsix"

    # Check if we can reuse the existing file because of the rate limit
    if (Test-Path -Path $vsixPath) {
        Write-Host "Reusing $vsixPath"
    }
    else {
        Write-Host "Downloading $DownloadUrl"
        
        # Due to rate limit error, keep retring until donwload is successful
		do {
			try {			
				$Response = Invoke-WebRequest -Uri $DownloadUrl -OutFile $vsixPath	
				# This will only execute if the Invoke-WebRequest is successful.
				$StatusCode = $Response.StatusCode
			}
			catch {				
				$StatusCode = $_.Exception.Response.StatusCode.value__
			}
			# Status code 429 : Too many Requests response status code, Re-try after sometime
			if($StatusCode -eq 429) {
				
				Write-Host "Failed to download due to rate limit error. Wait for 10 Seconds before re-try download"
				Start-Sleep -Seconds 10
			}		
			
		} while($StatusCode -eq 429)
    }

    $vsixInstaller = Get-ChildItem $vsixPath

    Write-Host "Installing $($vsixInstaller.Name)..."
    $vsixInstallerPath = "$env:ProgramFiles\Microsoft Visual Studio\2022\Professional\Common7\IDE\VSIXInstaller.exe"
    & $vsixInstallerPath /quiet /logFile:VSExtensions-2019-2022.log /admin $vsixInstaller.FullName

    Write-Host "Installation of $ExtensionName completed."
}


$extensions = @(
    "Aqovia.VisualStudio-ExtensionPack-2022"
)

Write-Host "Installing VS 2022 extensions..."
Write-Warning "You may face rate limit issues. If so, please wait a few minutes and try again."
Write-Warning "see the topic `"Rate limits`" on the Microsoft Web site (https://go.microsoft.com/fwlink/?LinkId=823950)."

$extensions | ForEach-Object {
    $extensionName = $_
    try {
        $downloadUrl = Get-VisualStudioExtensionDownloadLink -ExtensionName $extensionName
        Install-VisualStudio2022ExtensionByUrl -ExtensionName $extensionName -DownloadUrl $downloadUrl
    }
    catch {
        Write-Error "Failed to install $extensionName"
        Write-Error $_
    }
}
