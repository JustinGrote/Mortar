using namespace Microsoft.TemplateEngine.IDE
using namespace Microsoft.TemplateEngine.Edge
using namespace Microsoft.TemplateEngine.Abstractions.Installer
using namespace System.Threading

function Install-Template {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)][String]$Path
    )
    begin {
        [Bootstrapper]$client = Get-TemplateClient
    }
    process {
        [InstallRequest[]]$request = [InstallRequest]::new($path)
        $result = $client.InstallTemplatePackagesAsync(
            $request,
            'Global',
            [CancellationToken]::None
        )
        | Receive-Task

        if (-not $result.success) {
            Write-Error ('{0} ({1}): {2}' -f $result.error, $result.InstallRequest, $result.ErrorMessage)
            return
        }
        return $result
    }
}
