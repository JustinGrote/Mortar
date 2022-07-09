using namespace System.Collections.ObjectModel
using namespace System.Collections.Generic
using namespace System.Collections.Specialized
function ConvertTo-ReadOnlyStringDictionary {
    <#
        .SYNOPSIS
        Converts a hashtable to a ReadOnlyDictionary[String,String]. Needed for project args
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)][hashtable]$hashtable
    )
    process {
        $dictionary = [SortedDictionary[string, string]]::new([StringComparer]::OrdinalIgnoreCase)
        $hashtable.GetEnumerator().foreach{
            $dictionary[$_.Name] = $_.Value
        }
        [ReadOnlyDictionary[string, string]]::new($dictionary)
    }
}
