using namespace Microsoft.TemplateEngine.IDE
using namespace Microsoft.TemplateEngine.Edge
using namespace Microsoft.TemplateEngine.Abstractions.Installer
using namespace System.Threading

function Install-Template {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        #A path to where one or more templates are stored. This will search for proper template.json files within the directory to import.
        [parameter(ValueFromPipeline)][String]$Path,
        #Optionally specify a version for the template import
        [Version]$Version
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
            $path | Write-FunctionError "No templates found in $path. Templates must have a .templates.config/template.json file present"
            return
        }

        [InstallRequest[]]$request = foreach ($fileItem in $templateFiles) {
            [string]$templatePath = [IO.Directory]::GetParent($fileItem).Parent #Get the root template folder quickly
            Write-Verbose "Template Found at: $templatePath"
            [InstallRequest]::new($templatePath, $Version)
        }

        if (-not $PSCmdlet.ShouldProcess($Path, "Install $($request.count) templates found")) { return }

        $resultSet = $client.InstallTemplatePackagesAsync(
            $request,
            'Global',
            [CancellationToken]::None
        )
        | Receive-Task

        foreach ($result in $resultSet) {
            if (-not $result.success) {
                $result | Write-FunctionError ('{0} ({1}): {2}' -f $result.error, $result.InstallRequest, $result.ErrorMessage)
                continue
            }
            $result
        }
    }
}
