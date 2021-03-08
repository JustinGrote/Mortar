#region SourceInit
$publicFunctions = @()
foreach ($ScriptPathItem in 'Private','Public') {
    $ScriptSearchFilter = [io.path]::Combine($PSScriptRoot, $ScriptPathItem, '*.ps1')
    Get-ChildItem $ScriptSearchFilter | Foreach-Object {
        if ($ScriptPathItem -eq 'Public') {$PublicFunctions += $PSItem.BaseName}
        . $PSItem
    }
}
Export-ModuleMember -Function $publicFunctions
#endregion SourceInit

#TODO: Replace with finder system
$SCRIPT:templatePath = if (Test-Path "../templates") {Resolve-Path "../templates"} else {Resolve-Path 'templates'}