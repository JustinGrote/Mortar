using namespace Microsoft.TemplateEngine.IDE
using namespace Microsoft.TemplateEngine.Edge
using namespace Microsoft.TemplateEngine.Abstractions.Installer
using namespace System.Threading
using namespace Mortar

function Get-TemplateClient {
    [CmdletBinding()]
    [OutputType('Microsoft.TemplateEngine.IDE.Bootstrapper')]
    param(
        #A virtual client doesnt persist its config to disk.
        [Switch]$Virtual = $true #TODO: Load all components but the default packages provider instead
    )

    if (-not $SCRIPT:TemplateClient) {
        $SCRIPT:TemplateHost = [DefaultTemplateEngineHost]::new('Mortar', $version)
        $version = (Get-Module Mortar).Version
        [Bootstrapper]$client = [Bootstrapper]::new(
            $SCRIPT:TemplateHost,
            $Virtual, #virtualizeConfiguration
            $true, #loadDefaultComponents
            "$HOME/.config/powershell"
        )

        $factory = [PowerShellModuleTemplatePackageProviderFactory]::new()
        #Registers our Template Finder with the client.
        $client.AddComponent(
            [PowershellModuleTemplatePackageProviderFactory].GetInterface('ITemplatePackageProviderFactory'),
            $factory
        )
        $SCRIPT:TemplateClient = $client
    }

    return $SCRIPT:TemplateClient
}
