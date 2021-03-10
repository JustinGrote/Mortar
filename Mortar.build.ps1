#requires -module PowershellBuild
. PowerShellBuild.IB.Tasks
$PSBPreference.Build.CompileModule = $true
$PSBPreference.Build.Exclude = 'Mortar.build.ps1','src/Mortar.psm1'
$PSBPreference.Build.CopyDirectories = '../templates'
$PSBPreference.Build.CompileDirectories = $env:BHModulePath

Task RemoveSourceInit StageFiles, {
    #BUG: Exclude doesn't seem to work with the PowershellBuild psm1 file
    $compiledModulePath = Join-Path $PSBPreference.build.ModuleOutDir 'Mortar.psm1'
    $sourceInitRegionRegex = '(?s)#region SourceInit[\r\n]+.+#endregion SourceInit'
    $moduleContent = Get-Content -Raw $compiledModulePath
    $strippedModuleContent = $moduleContent -replace $sourceInitRegionRegex,''
    Out-File -InputObject $strippedModuleContent -FilePath $compiledModulePath -Force
}

Task Build StageFiles,RemoveSourceInit

Task . Build,Test