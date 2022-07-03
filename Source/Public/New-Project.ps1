using namespace Microsoft.TemplateEngine.Abstractions
using namespace Microsoft.TemplateEngine.IDE
using namespace Microsoft.TemplateEngine.Edge.Template
using namespace System.Collections.Generic
function New-Project {
    <#
    .SYNOPSIS
    Initiates a new project template
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        #Specify the template to use
        #TODO: Template discovery across modules
        [Parameter(Mandatory)]
        # [ArgumentCompleter({
        #     #TODO: Figure out a better way to handle paths for compiled vs source runs of this script
        #     $templatePath = if ((Split-Path $PSScriptRoot -Leaf) -eq 'Public') {"$PSScriptRoot/../../templates"} else {"$PSScriptRoot/templates"}
        #     (Get-ChildItem $templatePath).Name
        # })]
        [ITemplateInfo]$Template,
        #Path to apply the template
        [String]$Path = '.',
        #Name of the project. Defaults to folder Name
        [String]$Name = $((Get-Item $Path).Name),
        #The baseline configuration (set of predefined parameters) to use, if any.
        [String]$BaselineName,
        #TODO: Dynamic Params. For now this is an array of parameter followed by value e.g. @('--Author','JGrote')
        [hashtable]$Arguments = @{}
    )
    begin {
        [Bootstrapper]$client = Get-TemplateClient
    }
    end {
        $readOnlyArguments = ConvertTo-ReadOnlyStringDictionary $Arguments
        if ($PSCmdlet.ShouldProcess($Path, "Applying template $($Template.ShortName) ($($Template.Name))")) {
            #Install The Template
            $result = $client.CreateAsync(
                $Template,
                $Name,
                $Path,
                $readOnlyArguments,
                $BaselineName,
                [System.Threading.CancellationToken]::None
            )
            | Receive-Task

            if ($result.Status -ne [CreationResultStatus]::Success) {
                Write-FunctionError ('There was an error deploying the {0} template to {1}: [{2}] {3}' -f $result.TemplateFullName, $result.OutputBaseDirectory, $result.Status, $result.ErrorMessage)
                return
            }
            $result
        }
    }
}
