CMD /c "~/.passwords && set" | .{process{
    if ($_ -match '^([^=]+)=(.*)') {
        Set-Variable $matches[1] $matches[2]
    }
}}