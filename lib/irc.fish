function clean_chan -d 'Remove invalid channel name characters'
    echo $argv | tr -d ' \007,/.'
end

function join
    echo "JOIN $argv" >var/cmd
end

function part
    echo "PART $argv" >var/cmd
end
