
# Experimenting with NewBoundScriptBlock()

$m = new-module { $count = 0 }

$sb = $m.NewBoundScriptBlock({$scope:x++})

& $sb

$function:c1 = $sb

c1

$function:c2 = $m.NewBoundScriptBlock({($script:x++)})

c2

# Experimenting with GetNewClosure()

function New-Counter {
    $x = 0;
    {($script:x++)}.GetNewClosure()
}

# Create counter C1
$function:c1 = new-counter
c1

# Create counter c2
$function:c2 = new-counter
c2

# Simplified Concurrency (but it doesn't actually work...)

function New-Task ($sb) {[System.Threading.Tasks.Task]::new($sb)}

$msg = "Hello there"

$t = New-Task {[console]::WriteLine($msg)}.GetNewClosure()

$t.RunSynchronously()

