using namespace Microsoft.TemplateEngine.IDE
using namespace Microsoft.TemplateEngine.Edge
using namespace Microsoft.TemplateEngine.Abstractions.Installer
using namespace System.Threading

function Get-TemplateClient {
    [CmdletBinding()]
    [OutputType('Microsoft.TemplateEngine.IDE.Bootstrapper')]
    param(
        #A virtual client doesnt persist its config to disk. Useful for CI or Testing.
        [Switch]$Virtual
    )

    if (-not $SCRIPT:TemplateClient) {
        $version = (Get-Module Mortar).Version
        [Bootstrapper]$SCRIPT:TemplateClient = [Bootstrapper]::new(
            [DefaultTemplateEngineHost]::new('Mortar', $version),
            $Virtual, #virtualizeConfiguration
            $true, #loadDefaultComponents
            "$HOME/.config/powershell"
        )
    }
    return $SCRIPT:TemplateClient
}

