function Update-Template {
    <#
    .SYNOPSIS
    Searches your local PowerShell modules for template updates and installs them into the local engine
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $modulesWithTemplates = Get-ModuleManifestPaths
    | Get-ModuleFromPath
    | Get-ModulesWithTemplates

    foreach ($module in $modulesWithTemplates) {
        Write-Verbose "Detected templates in module $($module.Name)"
        if (-not $PSCmdlet.ShouldProcess($module.Name, 'Update Templates found in module')) {
            continue
        }
        Install-Template -Path (Split-Path $Module.Path) -Version $module.Version
    }
}


function Get-ModuleManifestPaths {
    <#
    .SYNOPSIS
    Finds all the templates in the various available module paths
    #>

    $pathSep = [io.path]::DirectorySeparatorChar
    #Find candidate modules
    [HashSet[string]]$manifestPaths = @()

    $candidatePaths = $env:psmodulepath -split ';'
    #Depth-first approach
    foreach ($rootDir in $candidatePaths) {
        foreach ($moduleFolder in [IO.Directory]::EnumerateDirectories($rootDir)) {
            $moduleName = Split-Path $moduleFolder -Leaf
            [string]$manifestPath = $moduleFolder + $pathSep + $ModuleName + '.psd1'
            if ([IO.File]::Exists($manifestPath)) {
                $null = $manifestPaths.Add($manifestPath)
                #We can somewhat safely assume if a .psd1 exists this is a "classic" module and wont have versioned folders
                continue
            }
            #Get version-based module folders and check them as well for manifests
            foreach ($versionFolder in ([IO.Directory]::EnumerateDirectories($moduleFolder, '*?.*?.*?'))) {
                [string]$manifestPath = $versionFolder + $pathSep + $ModuleName + '.psd1'
                if ([IO.File]::Exists($manifestPath)) { $null = $manifestPaths.Add($manifestPath) }
            }
        }
    }
    return $manifestPaths
}

filter Get-ModuleFromPath {
    Get-Module -ListAvailable -Name $PSItem
}

filter Get-ModulesWithTemplates {
    if ($PSItem.Tags -contains 'MortarTemplate') {
        return $PSItem
    }
}
