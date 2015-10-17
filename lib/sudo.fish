function sudoer -d 'Check if user is admin'
    # check global moderator list
    grep -Fxq $NICK etc/sudoers
    # then per chan list
    or grep -Fxq $NICK etc/sudoers.d/$CHAN ^/dev/null
    or begin
        echo "Aquaman says he doesn't like you."
        false
    end
end
