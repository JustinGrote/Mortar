#region SourceInit
#Load assemblies

$type = $null
[bool]$olderNugetDetected = try {
    $type = [NuGet.Versioning.NuGetVersion]
    $type.assembly.GetName().Version -lt '6.0.0'
} catch [Management.Automation.RuntimeException] { $false }
if ($olderNugetDetected) {
    throw "An older version of Nuget was detected at $($type.assembly.Location). Please load this module before loading this assembly (which is commonly PSGet 3.0)"
}
Add-Type -Path $PSScriptRoot/../Output/*.dll
Update-FormatData -PrependPath $PSScriptRoot/Types/*.format.ps1xml

$publicFunctions = @()
foreach ($ScriptPathItem in 'Classes', 'Utils', 'Private', 'Public') {
    $ScriptSearchFilter = [io.path]::Combine($PSScriptRoot, $ScriptPathItem, '*.ps1')
    $ScriptExcludeFilter = { $PSItem -notlike '*.tests.ps1' -and $PSItem -notlike '*.build.ps1' }
    Get-ChildItem $ScriptSearchFilter |
        Where-Object -FilterScript $ScriptExcludeFilter |
        ForEach-Object {
            if ($ScriptPathItem -eq 'Public') { $PublicFunctions += $PSItem.BaseName }
            . $PSItem
        }
}
Export-ModuleMember -Function $publicFunctions
#endregion SourceInit
