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
            $templatePath = if ((Split-Path $PSScriptRoot -Leaf) -eq 'Public') {"$PSScriptRoot/../../templates"} else {"$PSScriptRoot/templates"}
            (Get-ChildItem $templatePath).Name
        })]
        [String]$Template,
        #Path to apply the template
        [String]$Path = '.',
        #Name of the project. Defaults to folder Name
        [String]$Name = $((Get-Item $Path).Name),
        #TODO: Dynamic Params. For now this is an array of parameter followed by value e.g. @('--Author','JGrote')
        [String[]]$Arguments
    )
    end {
        if ($PSCmdlet.ShouldProcess($Path, "Applying template $Template")) {
            #TODO: Figure out a better way to handle paths for compiled vs source runs of this script
            $templateToApply = Join-Path $templatePath $template
            #Install The Template
            $dotnetImportOutput = & dotnet new -i $templateToApply
            #Strip Comments to convert to json
            $templateContent = Get-Content -Raw "$templateToApply/.template.config/template.json"
            $StripJsonCommentsRegex = '("(\\.|[^\\"])*")|/\*[\S\s]*?\*/|//.*'
            $templateSettings = $templateContent -replace $StripJsonCommentsRegex,'$1' |
                ConvertFrom-Json -WarningAction 'SilentlyContinue'
            #Fetch the module shortname
            $templateName = $templateSettings.Name

            $dotnetResult = & dotnet new "$templateName" -o $Path -n $Name @Arguments
            if ($dotnetResult -ne "The template `"$templateName`" was created successfully.") {
                throw "There was an error applying the template: $dotnetResult"
            }
        }
    }
}