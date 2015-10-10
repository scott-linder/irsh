function opts_find_sep -d 'Get index of -- separator from opts'
    set -l opts $argv
    set -l idx 1
    for opt in $opts
        if test $opt = "--"; break; end
        set idx (math "$idx + 1")
    end
    echo $idx
end

function opts_flags -d 'Get the flag arguments from opts'
    set -l sep $argv[1]
    set -l opts $argv[2..-1]
    if test $sep != 1
        echo $opts[1..(math "$sep - 1")] | tr ' ' \n
    end
end

function opts_rest -d 'Get the rest (positional) arguments from opts'
    set -l sep $argv[1]
    set -l opts $argv[2..-1]
    if test $sep != (count $opts)
        echo $opts[(math "$sep + 1")..-1] | tr ' ' \n
    end
end

function opts_getopts -d 'Parse commandline options from args'
    set -l fmt $argv[1]
    set -l args $argv[2]
    set args (echo $args | tr ' ' \n)
    set args (getopt -s sh $fmt $args)
    fish -c "for arg in $args; echo \$arg; end"
end

function opts -d 'Helper to parse options into $flags and $rest'
    set -l fmt $argv[1]
    set -l args $argv[2..-1]
    set -l opts (opts_getopts $fmt $args)
    set -l sep (opts_find_sep $opts)
    set -g flags (opts_flags $sep $opts)
    set -g rest (opts_rest $sep $opts)
end
