$global:PwrPackageConfig = @{
	Name = 'jre'
	Matcher = '^jre-8\.'
}

function global:Install-PwrPackage {
	$Params = @{
		Owner = 'adoptium'
		Repo = 'temurin8-binaries'
		AssetPattern = '^.*jre_x64_windows_hotspot_.+?\.zip$'
		TagPattern = "^jdk(8)u([0-9]+)[^']+$"
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
			java_home = (Split-Path (Get-ChildItem -Path '\pkg' -Recurse -Include 'bin' | Select-Object -First 1).FullName -Parent)
			path = (Get-ChildItem -Path '\pkg' -Recurse -Include 'java.exe' | Select-Object -First 1).DirectoryName
		}
	}
}

function global:Test-PwrPackageInstall {
	pwr sh 'file:///\pkg'
	java -version
	pwr exit
}