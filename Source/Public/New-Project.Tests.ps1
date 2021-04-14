Describe 'New-Project' {
    BeforeEach {
        Get-Module Mortar | Remove-Module
        Import-Module $PSScriptRoot/../Mortar.psd1 -force
    }


    It 'Deploys the <Name> template' {
        $testModulePath = New-Item -Force -ItemType Directory TestDrive:/Templates/$Name
        New-MortarProject -Template $Name -Path $testModulePath -Arguments $Arguments
        $filesToCheck.foreach{
            Resolve-Path $testModulePath/$PSItem
        }
    } -TestCases @(
        @{
            Name = '01-simple-module'
            Arguments = @()
            FilesToCheck = @(
                '01-simple-module.psm1'
            )
        }
        @{
            Name =  '02-simple-module-with-manifest'
            Arguments = @('--Author','PesterAuthor')
            FilesToCheck = @(
                '02-simple-module-with-manifest.psm1'
                '02-simple-module-with-manifest.psd1'
            )
        }
        @{
            Name = '03-powershell-module'
            Arguments = @('--Author','PesterAuthor')
            FilesToCheck = @(
                '03-powershell-module/03-powershell-module.psm1'
                '03-powershell-module/03-powershell-module.psd1'
                '03-powershell-module/Public'
                '03-powershell-module/Public/New-03-powershell-module.ps1'
                '03-powershell-module/Private/New-03-powershell-moduleAction.ps1'
                '03-powershell-module/Private'
            )
        }
    )
}