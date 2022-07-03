using namespace System.Diagnostics.CodeAnalysis
Describe ($MyInvocation.MyCommand.Name -replace '.Tests.ps1$') {
    BeforeAll {
        . $PSScriptRoot/../Tests/Shared.ps1
        Import-ModuleWithoutPrefix $PSScriptRoot/../Mortar.psd1 -force

        Test-WithVirtualClient

        [SuppressMessageAttribute(
            'PSUseDeclaredVarsMoreThanAssignments',
            'PSScriptAnalyzer',
            Justification = 'This is used outside BeforeAll but PSScriptAnalyzer doesnt see the relationship due to how Pester loads scriptblocks'
        )]
        $TemplatesPath = "$PSScriptRoot/../../Templates"

        $ErrorActionPreference = 'stop'
    }
    Context 'Single Template' {
        It 'Adds the <Name> template' {
            $PathToImport = Resolve-Path (Join-Path $TemplatesPath $Name)
            (Install-Template $PathToImport -ErrorAction Stop).Success | Should -BeTrue
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

        It 'Shows error if template already exists' {
            Test-WithVirtualClient
            $Name = '01-simple-module'
            $PathToImport = Resolve-Path (Join-Path $TemplatesPath $Name)

            (Install-Template $PathToImport).Success | Should -BeTrue

            $err = Install-Template $PathToImport 2>&1
            $err | Should -BeLike 'AlreadyInstalled*'
        }
    }

    Context 'Multiple Templates' {
        BeforeEach {
            Test-WithVirtualClient
        }
        It 'Installs multiple templates found in a directory' {
            $PathToImport = Resolve-Path $TemplatesPath

            $result = (Install-Template $PathToImport).Success
            $result.count | Should -Be 3
            $result | ForEach-Object { $result | Should -BeTrue }
        }
    }
}
