
# ScriptBlock has a Module member... 
{}.Module

# Experimenting with NewBoundScriptBlock()

$m = New-Module { $count = 0 }

$sb = $m.NewBoundScriptBlock({($script:count++)})

& $sb

$sb.Module

$sb.Module.SessionState

& $sb.Module {$script:count = 0}

$function:c1 = $sb

c1

$function:c2 = $m.NewBoundScriptBlock({($script:x++)})

c2

# Experimenting with the GetNewClosure() API

function New-Counter ($x = 0) {
    {($script:x++)}.GetNewClosure()
}

# Create counter C1
$function:c1 = new-counter
c1

# Create counter c2
$function:c2 = new-counter 100
c2

# What are closures good for?

# Simplified Concurrency (but it doesn't actually work...)

function New-Task ($sb) {[System.Threading.Tasks.Task]::new($sb)}

$msg = "Hello there"

$t = New-Task {[console]::WriteLine($msg)}.GetNewClosure()

$t.RunSynchronously()

