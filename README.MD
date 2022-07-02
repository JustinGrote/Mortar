# Mortar
A templating engine for Powershell leveraging the dotnet templating engine, inspired by Plaster.

## Goals
1. Don't reinvent the wheel, templating has been done by dotnet and is mature, long term supported, and stable.
1. Make interaction with the dotnet templating engine as comfortable for a casual Powershell user who has little to no .NET knowledge as possible.
1. Friendly functions to consume templates in .nupkg format from the Powershell Gallery (and potentially nuget.org). Align with `PSGet 3.0` as much as possible for methodology.

## Non-Goals
1. Adding extensive advanced templating functionality above and beyond what the dotnet templating engine offers. This is basically a transpiler to `template.json`. See `Pulumi` and `Bicep` for inspiration.

## Prototype Design
### Template development
template.json has a JSON schema so tooling/autocomplete work in vscode natively, leverage this
`New-MortarTemplate` for the template scaffolding (will be very limited customization but lots of comments)
### Template Deployment
`New-MortarProject` (and maybe `Invoke-Mortar`) to deploy new template.
wrap `dotnet new` for project creation initially, move to using the native assemblies later

### Template Distribution
PSGallery modules can implement a PSData option specifying the path to the modules to import

## Future
1. DSL maybe? Worth the effort over existing json tooling? Probably not
1. Plaster "Shim" so that Mortar can maybe be used with the vscode plaster deployment. Alternatively, just make a new action for mortar templates using same flow as C# extension
1. PSD1 to template.json transpiler, probably not worth it, most PS people are comfortable with json these days.
1. There is a JSON schema for the templating engine (https://json.schemastore.org/template), use QuickType to generate C# classes to build/validate a config maybe?
1. Wrap the quicktype generator with powershell functions that would be familiar to someone who has used new-modulemanifest.

## Native Assembly Approach
1. Use the bootstrapper class mentioned here: https://github.com/dotnet/templating/blob/main/docs/api/Inside-the-Template-Engine.md
1. Add a provider that can search for the provided PSData (tag?) templates locally
