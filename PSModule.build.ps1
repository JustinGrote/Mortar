#requires -version 7
Install-Module Press -RequiredVersion '0.3.0-beta0033' -AllowPrerelease
Import-Module Press -RequiredVersion '0.3.0'
. Press.Tasks

#TODO: Replace this with using the existing task and a settings variable
Task CopyTemplates -After Press.CopyModuleFiles {
    Copy-Item -Path "$($PressSetting.General.ProjectRoot)/Templates" -Destination "$($PressSetting.Build.ModuleOutDir)/Templates" -Recurse -Force
}