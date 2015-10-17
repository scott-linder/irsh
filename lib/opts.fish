function opts_find_sep -d 'Get index of -- separator from opts'
    set -l opts $argv
    set -l idx 1
    for opt in $opts
        if test $opt = "--"; break; end
        set idx (math "$idx + 1")
    end
    echo $idx
end

function opts_getopts -d 'Parse commandline options from args'
    set -l fmt $argv[1]
    set -l args ''
    if test (count $argv) -gt 1
        set args $argv[2..-1]
    end
    set args (getopt -s sh $fmt $args)
    fish -c "for arg in $args; echo \$arg; end"
end

function opts -d 'Helper to parse options into $flags and $argv'
    set -l fmt $argv[1]
    set -l args ''
    if test (count $argv) -gt 1
        set args $argv[2..-1]
    end
    set -l opts (opts_getopts $fmt $args)
    set -l sep (opts_find_sep $opts)
    set -g flags
    set -g pos
    if test $sep != 1
        set flags $opts[1..(math $sep-1)]
    end
    if test $sep != (count $opts)
        set pos $opts[(math $sep+1)..-1]
    end
end
