# Mortar
A templating engine for Powershell leveraging the dotnet templating engine

## Prototype Design
1. There is a JSON schema for the templating engine (https://json.schemastore.org/template), use QuickType to generate C# classes to build the config.
1. Wrap the quicktype generator with powershell functions that would be familiar to someone who has used new-modulemanifest.
1. For template deployment, wrap `dotnet new` for project creation initially, move to using the assemblies next

## Future
1. DSL maybe?
1. Plaster "Shim" so that Mortar can maybe be used with the vscode plaster deployment. Alternatively, just make a new action for mortar templates using same flow as C# extension
1. PSD1 to template.json transpiler, probably not worth it, most PS people are comfortable with json these days.
