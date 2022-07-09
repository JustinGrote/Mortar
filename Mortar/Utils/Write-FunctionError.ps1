using namespace System.Management.Automation
using namespace Microsoft.PowerShell.Commands
function Write-FunctionError {
<#
.SYNOPSIS
Writes an error within the context of the containing CmdletBinding() function. Makes errr displays prettier
#>
    param(
        [Parameter(Mandatory)][String]$Message,
        [ValidateNotNullOrEmpty()][ErrorCategory]$Category = 'WriteError',
        [ValidateNotNullOrEmpty()][String]$Id = 'FunctionError',
        [Parameter(ValueFromPipeline)]$TargetObject
    )
    [PSCmdlet]$context = (Get-Variable -Scope 1 'PSCmdlet' -ErrorAction Stop).Value
    if (-not $context) { throw 'Write-FunctionError must be used in the context of a cmdlet with [CmdletBinding()] applied' }
    $exception = [WriteErrorException]$Message
    $errorRecord = [ErrorRecord]::new(
        $exception,
        $Id,
        $Category,
        $TargetObject
    )
    $context.WriteError($errorRecord)
}
