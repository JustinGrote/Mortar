using System;
using System.Collections;
using System.Management.Automation.Language;
using System.Runtime.CompilerServices;
using Microsoft.TemplateEngine.Abstractions;
using Microsoft.TemplateEngine.Abstractions.TemplatePackage;

namespace Mortar;
public class PowerShellModuleTemplatePackageProvider : ITemplatePackageProvider
{
    public ITemplatePackageProviderFactory Factory { get; }
    public event Action? TemplatePackagesChanged; //TODO: Implement a filewatcher that will trigger this

    public PowerShellModuleTemplatePackageProvider(ITemplatePackageProviderFactory factory)
    {
        Factory = factory;
    }

    public Task<IReadOnlyList<ITemplatePackage>> GetAllTemplatePackagesAsync(CancellationToken token)
    {
        // Search for all PowerShell modules in the current directory

        var PSModulePath = Environment.GetEnvironmentVariable("PSModulePath") ?? throw new InvalidOperationException("PSModulePath is not avaliable as an environment variable. This should never happen.");
        var moduleSearchPaths = PSModulePath.Split(Path.PathSeparator);
        HashSet<string> manifestPaths = new();
        foreach (var path in moduleSearchPaths)
        {
            foreach (var moduleFolder in Directory.EnumerateDirectories(path))
            {
                token.ThrowIfCancellationRequested();
                var moduleName = new DirectoryInfo(moduleFolder).Name;
                var manifestPath = Path.Join(moduleFolder, moduleName + ".psd1");
                if (File.Exists(manifestPath))
                {
                    manifestPaths.Add(manifestPath);
                    // We can somewhat safely assume if a.psd1 exists this is a "classic" module and wont have versioned folders
                    continue;
                }
                //HACK: This is an approximate search for version folders due to limitation of filter syntax. We still will verify by checking for a manifest file in the proper location
                foreach (var versionFolder in Directory.EnumerateDirectories(moduleFolder, "*?.*?.*?"))
                {
                    var versionedManifestPath = Path.Join(versionFolder, moduleName + ".psd1");
                    if (File.Exists(versionedManifestPath))
                    {
                        manifestPaths.Add(versionedManifestPath);
                    }
                }
            }
        }

        // Get only templates that have the 'MortarTemplate' tag
        IEnumerable<string> templateManifestPaths = manifestPaths.Where(p =>
        {
            // Adapted from Import-PowerShellDataFile implementation
            Ast ast = Parser.ParseFile(p, out _, out _);
            Ast data = ast.Find(static a => a is HashtableAst, false);

            Hashtable? manifest;
            try
            {
                manifest = data.SafeGetValue() as Hashtable;
            }
            catch
            {
                manifest = null;
            }
            if (manifest is null)
            {
                return false;
            }
            if (manifest["PrivateData"] is not Hashtable privateData)
            {
                return false;
            }
            if (privateData["PSData"] is not Hashtable psData)
            {
                return false;
            }
            // FIXME: Make this configurable
            const string templateTag = "MortarTemplate";
            return psData["Tags"] switch
            {
                string tag => tag == templateTag,
                string[] tags => tags.Contains(templateTag),
                _ => false,
            };
        });

        IEnumerable<DirectoryInfo> templateFolders = templateManifestPaths.SelectMany(
            manifestPath =>
            {
                DirectoryInfo manifestFolderPath = Directory.GetParent(manifestPath) ??
                    throw new InvalidOperationException("Could not get parent folder of manifest file. This should never happen.");

                EnumerationOptions limitSearchDepth = new()
                {
                    RecurseSubdirectories = true,
                    // We want to avoid really crazy module template architectures, or mislabeled modules killing search performance
                    // So we support up to something like Templates/MyTemplate/1.0.0/.template.config/template.json
                    MaxRecursionDepth = 3
                };

                return from candidate in manifestFolderPath.EnumerateDirectories(".template.config", limitSearchDepth)
                       where File.Exists(Path.Join(candidate.FullName, "template.json"))
                       select candidate.Parent;
            }
        );

        var discoveredTemplatePackages = templateFolders.Select(
            folder =>
            {
                return new TemplatePackage(
                    this,
                    folder.FullName,
                    folder.LastWriteTimeUtc
                );
            }
        ).ToList();

        return Task.FromResult<IReadOnlyList<ITemplatePackage>>(discoveredTemplatePackages);
    }
}

/// <summary>
/// Creates <see cref="PowerShellModuleTemplateProvider"/> instances. Supply this to the bootstrapper AddComponent interface
/// </summary>
public class PowerShellModuleTemplatePackageProviderFactory : ITemplatePackageProviderFactory
{
    public Guid Id { get; } = new("fdd52a92-307a-4a93-ad0c-23107f40add1");
    public string DisplayName { get; } = "Mortar - PowerShell Module Templates";
    public List<PowerShellModuleTemplatePackageProvider> Providers { get; } = new();

    public ITemplatePackageProvider CreateProvider(IEngineEnvironmentSettings settings)
    {
        PowerShellModuleTemplatePackageProvider provider = new(this);
        Providers.Add(provider);
        return provider;
    }
}
