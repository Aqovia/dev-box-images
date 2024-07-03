ridk install 2 3

$RubyInterpreters = Get-Command ruby
foreach ($interpreter in $rubyInterpreters) {
    $RubyPath = ($interpreter).Path
    $RuleName = "Ruby interpreter ($RubyPath)"

    try {
        Get-NetFirewallRule -DisplayName $RuleName -ErrorAction Stop
    }

    catch {
        "Could not find firewall rule, hence creating"
        New-NetFirewallRule `
            -DisplayName $RuleName `
            -Program ($interpreter).Path -Profile @('Domain', 'Private')  `
            -Direction Inbound `
            -Action Allow
    }

}


