using namespace System.Threading
function Get-Template {
    param(
        #TODO: $Name (which converts to $filter)
        #TODO: $Filter
    )
    $client = Get-TemplateClient
    #TODO: Use taskjob module
    $client.GetTemplatesAsync([CancellationToken]::None)
    | Receive-Task
}
