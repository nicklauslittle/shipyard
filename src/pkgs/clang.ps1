$global:PwrPackageConfig = @{
	Name = 'clang'
}

function global:Install-PwrPackage {
	$Params = @{
		Owner = 'llvm'
		Repo = 'llvm-project'
		AssetPattern = '^LLVM-.+-win64\.exe$'
		TagPattern = '^llvmorg-([0-9]+)\.([0-9]+)\.([0-9]+)$'
	}
	$Asset = Get-GitHubRelease @Params
	$PwrPackageConfig.UpToDate = -not $Asset.Version.LaterThan($PwrPackageConfig.Latest)
	$PwrPackageConfig.Version = $Asset.Version.ToString()
	if ($PwrPackageConfig.UpToDate) {
		return
	}
	# Download llvm
	$llvm = "$env:Temp\$($Asset.Name)"
	Invoke-WebRequest -UseBasicParsing $Asset.URL -OutFile $llvm
	# Unpack llvm
	pwr sh 7-zip
	7z x -o'\pkg' $llvm | Out-Null
	pwr exit
	Write-PackageVars @{
		env = @{
			path = (Get-ChildItem -Path '\pkg' -Recurse -Include 'clang.exe' | Select-Object -First 1).DirectoryName
		}
	}
}

function global:Test-PwrPackageInstall {
	pwr sh 'file:///\pkg'
	clang --version
	pwr exit
}