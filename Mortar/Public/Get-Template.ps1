using namespace System.Threading
using namespace System.Collections.Generic
function Get-Template {
    param(
        #TODO: $Name (which converts to $filter)
        #TODO: $Filter
    )
    $client = Get-TemplateClient
    #TODO: Use filter expression to only get PowerShell templates
    $client.GetTemplatesAsync([CancellationToken]::None)
    | Receive-Task
    | Where-Object { $_.tags.language.Choices.Keys.Contains('PowerShell') }
}
