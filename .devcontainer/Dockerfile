# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.238.1/containers/dotnet/.devcontainer/base.Dockerfile

# [Choice] .NET version: 6.0, 3.1, 6.0-bullseye, 3.1-bullseye, 6.0-focal, 3.1-focal
ARG VARIANT="6.0-bullseye-slim"
FROM mcr.microsoft.com/vscode/devcontainers/dotnet:0-${VARIANT}

# [Choice] Node.js version: none, lts/*, 18, 16, 14
ARG NODE_VERSION="none"
# [Choice] Prompt Theme: https://ohmyposh.dev/docs/themes
ARG OMP_THEME="spaceship"

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

#We do this here instead of using devcontainer.json due to codespaces not supporting WaitFor yet: https://github.com/github-community/community/discussions/9644
SHELL ["/usr/bin/pwsh", "-noprofile", "-command"]
USER vscode
COPY Scripts/Install-OhMyPosh.ps1 /tmp
RUN /tmp/Install-OhMyPosh.ps1 -Theme $env:OMP_THEME