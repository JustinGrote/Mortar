Describe ($MyInvocation.MyCommand.Name -replace '.Tests.ps1$') {
    BeforeAll {
        . $PSScriptRoot/../Tests/Shared.ps1
        Import-ModuleWithoutPrefix $PSScriptRoot/../Mortar.psd1 -force
        $TemplatesPath = "$PSScriptRoot/../../Templates"
        $ErrorActionPreference = 'stop'
    }

    It 'Adds the <Name> template' {
        $PathToImport = Resolve-Path (Join-Path $TemplatesPath $Name)
        (Install-Template $PathToImport).Success
        | Should -BeTrue
    } -TestCases @(
        @{
            Name = '01-simple-module'
        }
        @{
            Name = '02-simple-module-with-manifest'
        }
        @{
            Name = '03-powershell-module'
        }
    )

    It 'Shows error if template is attempted to be re-added' {
        #Reset any past state
        Import-ModuleWithoutPrefix $PSScriptRoot/../Mortar.psd1 -force
        $PathToImport = Resolve-Path (Join-Path $TemplatesPath '01-simple-module')

        (Install-Template $PathToImport).Success
        | Should -BeTrue

        $err = Install-Template $PathToImport 2>&1
        $err | Should -BeLike 'AlreadyInstalled*'
    }
}
