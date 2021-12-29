$global:PwrPackageConfig = @{
	Name = 'cmake'
}

function global:Install-PwrPackage {
	$Params = @{
		Owner = 'Kitware'
		Repo = 'CMake'
		AssetPattern = '^.*-windows-x86_64\.zip$'
		TagPattern = '^.*([0-9]+)\.([0-9]+)\.([0-9]+).*$'
	}
	$Asset = Get-GitHubRelease @Params
	$PwrPackageConfig.UpToDate = -not $Asset.Version.LaterThan($PwrPackageConfig.Latest)
	$PwrPackageConfig.Version = $Asset.Version.ToString()
	if ($PwrPackageConfig.UpToDate) {
		return
	}
	$Params = @{
		AssetName = $Asset.Name
		AssetIdentifier = $Asset.Identifier
		AssetURL = $Asset.URL
	}
	Install-BuildTool @Params
	Write-PackageVars @{
		env = @{
			path = (Get-ChildItem -Path '\pkg' -Recurse -Include 'cmake.exe' | Select-Object -First 1).DirectoryName
		}
	}
}

function global:Test-PwrPackageInstall {
	Get-Content '\pkg\.pwr'
}