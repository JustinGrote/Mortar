#requires -module Press
. Press.Tasks

#TODO: Replace this with using the existing task and a settings variable
# Task CopyTemplates -After Press.CopyModuleFiles {
#     Copy-Item -Path "$($PressSetting.General.ProjectRoot)/Templates" -Destination "$($PressSetting.Build.ModuleOutDir)/Templates" -Recurse -Force
# }
