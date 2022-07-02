using namespace Microsoft.TemplateEngine.IDE
using namespace Microsoft.TemplateEngine.Edge
using namespace Microsoft.TemplateEngine.Abstractions.Installer
using namespace System.Threading

function Get-TemplateClient {
    [CmdletBinding()]
    [OutputType('Microsoft.TemplateEngine.IDE.Bootstrapper')]
    param()

    if (-not $SCRIPT:TemplateClient) {
        [Bootstrapper]$SCRIPT:TemplateClient = [Bootstrapper]::new(
            [DefaultTemplateEngineHost]::new('Mortar', '0.0.0'),
            $true #virtualizeConfiguration,
        )
    }
    return $SCRIPT:TemplateClient
}

