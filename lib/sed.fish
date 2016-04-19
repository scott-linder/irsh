function sed_escape_regexp -d 'Escape regexp argument to sed s command (assuming / as separator)'
    echo $argv | sed 's#[]\\/$*.^|[]#\\\\&#g'
end

function sed_escape_replacement -d 'Escape replacement argument to sed s command (assuming / as separator)'
    echo $argv | sed 's#[\\/&]#\\\\&#g'
end
