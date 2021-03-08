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
        [ArgumentCompleter({
            #TODO: Figure out a better way to handle paths for compiled vs source runs of this script
            $templatePath = if ((Split-Path $PSScriptRoot -Leaf) -eq 'Public') {'../../templates'} else {'templates'}
            (Get-ChildItem $templatePath).Name
        })]
        [String]$Template,
        #Path to apply the template
        [String]$Path = '.',
        #Name of the project. Defaults to folder Name
        [String]$Name = $((Get-Item $Path).Name)
    )
    end {
        if ($PSCmdlet.ShouldProcess($Path, "Applying template $Template")) {
            #TODO: Figure out a better way to handle paths for compiled vs source runs of this script
            $templateToApply = Join-Path $templatePath $template
            #Install The Template
            $dotnetImportOutput = & dotnet new -i $templateToApply
            #Fetch the module shortname
            $templateName = (Get-Content $templateToApply/.template.config/template.json | 
                ConvertFrom-Json -Depth 5 -WarningAction SilentlyContinue).Name

            $dotnetResult = & dotnet new "$templateName" -o $Path -n $Name
            if ($dotnetResult -ne "The template `"$templateName`" was created successfully.") {
                throw "There was an error applying the template: $dotnetResult"
            }
        }
    }
}