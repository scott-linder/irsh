function sudoer -d 'Check if user is admin'
    grep -Fxq $NICK etc/sudoers
    or begin
        printf "Aquaman says he doesn't like you."
        false
    end
end
