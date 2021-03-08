

Describe 'New-Project' {
    BeforeEach {
        Get-Module Mortar | Remove-Module
        Import-Module $PSScriptRoot/../src/Mortar.psd1 -force
    }
    It 'Deploys the simple module template' {
        $testModulePath = New-Item -ItemType Directory TestDrive:/MyTestModule
        New-MortarProject -Template '01-simple-module' -Path $testModulePath
        $testModule = Resolve-Path TestDrive:/MyTestModule/MyTestModule.psm1
    }
}