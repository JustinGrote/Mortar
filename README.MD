# Mortar
A templating engine for Powershell leveraging the dotnet templating engine, inspired by Plaster.

## Objectives and Guiding Principles
1. Don't reinvent the wheel, templating has been done by dotnet and is mature, long term supported, and stable.
1. Make interaction with the dotnet templating engine as comfortable for a casual Powershell user who has little to no .NET knowledge as possible.
1. Friendly functions to consume templates in .nupkg format from the Powershell Gallery (and potentially nuget.org). Align with `PSGet 3.0` as much as possible for methodology.

## Non-Goals
1. Adding extensive advanced templating functionality above and beyond what the dotnet templating engine offers. This is basically a transpiler to `template.json`. See `Pulumi` and `Bicep` for inspiration.

## First Release Deliverables
1. Install dotnet templates from a local directry
2. Discover and install mechanism for templates on the PowerShell gallery
3. Deploy/Apply templates via `New-MortarProject`

## Future
1. Support template.yaml transparently
1. Custom template provider at the template .NET level rather than using PS
1. DSL maybe? Worth the effort over existing json tooling? Probably not
1. Plaster "Shim" so that Mortar can maybe be used with the vscode plaster deployment. Alternatively, just make a new action for mortar templates using same flow as C# extension
1. PSD1 to template.json transpiler, probably not worth it, most PS people are comfortable with json these days.
1. There is a JSON schema for the templating engine (https://json.schemastore.org/template), use QuickType to generate C# classes to build/validate a config maybe?
1. Wrap the quicktype generator with powershell functions that would be familiar to someone who has used new-modulemanifest.
