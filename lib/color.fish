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

set RAINBOW_COLORS '05' '04' '07' '08' '03' '09' '10' '11' '02' '12' '06' '13'
set RAINBOW_WORDS_COLORS '04' '08' '09' '11' '12' '13'

function rainbow
    set -l i 0
    for char in (echo $argv[1] | lib/chars)
        set i (math $i%(count $RAINBOW_COLORS)+1)
        color $RAINBOW_COLORS[$i]
        echo -n $char
    end
    color
end

function rainbow_words
    set -l i 0
    for word in (echo $argv[1] | lib/words)
        set i (math $i%(count $RAINBOW_WORDS_COLORS)+1)
        color $RAINBOW_WORDS_COLORS[$i]
        echo -n $word' '
    end
    color
end
