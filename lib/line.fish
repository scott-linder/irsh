function line_add -d "Add a line to a file"
    set -l line $argv[1]
    set -l file $argv[2]
    echo $line >> $file
    sort -u $file -o $file
end

function line_del -d "Delete a line to a file"
    set -l line $argv[1]
    set -l file $argv[2]
    sed -i "/$line/d" $file
end
