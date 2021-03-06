#region SourceInit
$publicFunctions = @()
foreach ($ScriptPathItem in 'Private','Public') {
    $ScriptSearchFilter = [io.path]::Combine($PSScriptRoot, $ScriptPathItem, '*.ps1')
    $ScriptExcludeFilter = {$PSItem -notlike '*.tests.ps1' -and $PSItem -notlike '*.build.ps1'}
    Get-ChildItem $ScriptSearchFilter |
        Where-Object -FilterScript $ScriptExcludeFilter |
        Foreach-Object {
            if ($ScriptPathItem -eq 'Public') {$PublicFunctions += $PSItem.BaseName}
            . $PSItem
        }
}
Export-ModuleMember -Function $publicFunctions
#endregion SourceInit


#TODO: Replace with finder system
$SCRIPT:templatePath = if (Test-Path "$PSScriptRoot/../Templates") {Resolve-Path "$PSScriptRoot/../Templates"} else {Resolve-Path 'Templates'}