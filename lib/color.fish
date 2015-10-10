function color
    if test (count $argv) -eq 1
        echo -n \3$argv[1]
    else
        echo -n \3
    end
end

function random_color
    color (math (random)%9+3)
end

function rainbow
    set -l color '05' '04' '07' '08' '03' '09' '10' '11' '02' '12' '06' '13'
    set -l i 0
    for char in (echo $argv[1] | fold -w1)
        set i (math $i%(count $color)+1)
        color $color[$i]
        echo -n $char
    end
    color
end
