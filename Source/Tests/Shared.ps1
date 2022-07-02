
#Workaround for https://github.com/PowerShell/PowerShell/issues/16936
function SCRIPT:Import-ModuleWithoutPrefix {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]$ManifestPath = "$PSScriptRoot/../$ModuleName.psd1",
        [Switch]$Force,
        $TempPath = 'TEMP:'
    )
    $path = Resolve-Path $ManifestPath
    $manifestDir = Split-Path $Path -Parent
    $fileName = [io.path]::GetFileNameWithoutExtension($path)
    #Manifest file name must be the same
    $tempPath = "TEMP:\$(New-Guid)\$fileName.psd1"

    $manifestContent = Get-Content -Raw $path
    $rootModuleRegex = '(?<=RootModule\s*?=\s*?[''"])(.+?)(?=[''"])'
    if ($manifestContent -notmatch $rootModuleRegex) {
        throw "Could not find RootModule entry in manifest $path"
    }
    $rootModulePath = [io.path]::IsPathRooted($matches[1]) ? $matches[1] : $(Join-Path $manifestDir $matches[1])
    $resolvedRootModulePath = Resolve-Path $rootModulePath
    $manifestContent = $manifestContent -replace $rootModuleRegex, $resolvedRootModulePath

    #Remove any prefix entry present. If this doesn't exist we don't error out
    $manifestContent = $manifestContent -replace 'DefaultCommandPrefix\s*?=\s*?[''"].+?[''"]'

    #This should be unique
    New-Item -ItemType File -Force -Path $tempPath -Value $manifestContent | Out-Null

    Write-Verbose "Importing module $path without prefix from $tempPath"
    Import-Module $tempPath -Force:$Force
}
