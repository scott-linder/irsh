function sed_escape_regexp -d 'Escape regexp argument to sed s command (assuming / as separator)'
    printf "%s" "$argv" | sed 's#[]\\/$*.^|[]#\\\\&#g'
end

function sed_escape_replacement -d 'Escape replacement argument to sed s command (assuming / as separator)'
    printf "%s" "$argv" | sed 's#[\\/&]#\\\\&#g'
end

function sed_escape_separator -d 'Escape only the separator to a sed command component (assuming / as a separator)'
    printf "%s" "$argv" | sed 's#/#\\\/#'
end
