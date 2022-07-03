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
        #TODO: Add YAML Support
        $templateFileName = 'template.json'#, 'template.yaml'
        $templateDirName = '.template.config'
    }
    process {
        #We want this to be fast so we drop to .NET method usage
        $templateFiles = foreach ($name in $templateFileName) {
            [IO.Directory]::EnumerateFiles($path, $name, 'AllDirectories')
            | Where-Object { [IO.Directory]::GetParent($PSItem).BaseName -eq $templateDirName }
        }

        if (-not $templateFiles) {
            Write-Error "No templates found in $path. Templates must have a .templates.config/template.json file present"
            return
        }


        [InstallRequest[]]$request = foreach ($fileItem in $templateFiles) {
            [string]$templatePath = [IO.Directory]::GetParent($fileItem).Parent #Get the root template folder quickly
            [InstallRequest]::new($templatePath)
        }

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
