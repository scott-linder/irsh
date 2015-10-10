function sudoer -d 'Check if user is admin'
    # channels are only moderated if they have a file in sudoers.d
    if test -f etc/sudoers.d/$CHAN
        # check global moderator list
        grep -Fxq $NICK etc/sudoers
        # then per chan list
        or grep -Fxq $NICK etc/sudoers.d/$CHAN
        or begin
            echo "Aquaman says he doesn't like you."
            false
        end
    else
        true
    end
end
