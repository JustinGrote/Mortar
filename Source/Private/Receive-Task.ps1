using namespace System.Threading.Tasks
using namespace System.Collections.Generic
filter Receive-Task {
    #Wait on one or more tasks in a cancellable manner
    [CmdletBinding()]
    param(
        [parameter(Mandatory, ValueFromPipeline)][Task]$Task,
        #How long to wait before checking for a cancellation in milliseconds
        [int]$WaitInterval = 500
    )
    begin {
        [List[Task]]$Tasks = @()
    }
    process {
        $Tasks.Add($Task)
    }
    end {
        while ($Tasks.count -gt 0) {
            $completedTaskIndex = [Task]::WaitAny($Tasks, $WaitInterval)
            if ($completedTaskIndex -eq -1) {
                #Timeout occured, this provides an opportunity to cancel before waiting again
                continue
            }
            $completedTask = $Tasks[$completedTaskIndex]
            $Tasks.RemoveAt($completedTaskIndex)
            #We use this instead of .Result so we get a proper exception if one was thrown instead of AggregateException
            #Reference: https://stackoverflow.com/questions/17284517/is-task-result-the-same-as-getawaiter-getresult/38530225#38530225
            $completedTask.GetAwaiter().GetResult()
        }
    }
}
