param(
  $theme = $ENV:OHMYPOSH_THEME ?? 'spaceship',
  $binPath = "$HOME/bin",
  $themePath = "$HOME/.config/oh-my-posh/themes",
  $pwshProfilePath = $profile.CurrentUserAllHosts
)
Start-Transcript $HOME/devcontainer-oncreate.log
trap {
  Stop-Transcript
  "An error occured: $PSItem"
}
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
#Create our folder scaffolding
@(
  $binPath
  $themePath
  (Split-Path $pwshProfilePath)
) | ForEach-Object {
  New-Item -Force -ItemType Directory $PSItem
} | Out-Null

#Fetch oh-my-posh
$ompBin = Join-Path $binPath 'oh-my-posh'
Invoke-WebRequest -Uri 'https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64' -OutFile $ompBin
& chmod +x $ompBin


$themeTempPath = 'TEMP:/themes.zip'
Invoke-WebRequest -Uri https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -OutFile $themeTempPath
Expand-Archive -Path $themeTempPath -DestinationPath $themePath | Out-Null
& chmod 644 $themePath/*
Remove-Item $themeTempPath
$themePath = Resolve-Path "$HOME/.config/oh-my-posh/themes/$theme.omp.json"

'oh-my-posh init pwsh --config {0} | Invoke-Expression' -f $themePath >> $pwshProfilePath
'eval "$(oh-my-posh init bash --config {0})"' -f $themePath >> ~/.bashrc
'eval "$(oh-my-posh init zsh --config {0})"' -f $themePath >> ~/.zshrc
