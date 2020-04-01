irsh
====

Internet Relay SHell

Etymology
---------

This is actually a [Matrix](https://matrix.org/) bot. The name is a hold-over
from when this was an IRC bot, and because "Internet Relay Shell" sounds cooler
than "Matrix Shell".

Rationale
---------

Both Matrix and Unix shells share a largely text-based interface. Many Matrix
bots follow the pattern of invoking commands and passing arguments, but do not
allow for composition of commands. The Unix shell (through pipes and
redirection) makes composition of commands and filters simple.

Thus irsh hopes to achieve the same, but in the restricted context of a Matrix
room, and with the reuse of as many Unix utilities as possible (with only
slight interface modifications).

Usage
-----

Create a configuration file `etc/irsh.ini`:

    [irsh]
    url = localhost
    username = irsh
    leader = $
    maxpipes = 5
    timeout = 5

The leader will prefix all commands.

I am not particularly disciplined about documenting how to set up the
environment, so I've just included a `Dockerfile` based on Alpine which I am
forced to keep up to date. Please use that, or set up an equivalent environment
and then run `init` from the root of the repository.

The bot will join any rooms it is invited to.

Overview
--------

The bot's core (`init`) is written in Python3 and requires only the
`matrix_nio` library.

The rest of the bot is intended to be written in Unix shell, specifically
[fish](http://fishshell.com/).

Filesystem
----------

The layout of the source directory is similar to a modern Unix filesystem:

    init - perhaps more aptly just `sh`
    bin/ - commands
    etc/ - configuration
    lib/ - libraries and utility functions (for both `init` and commands)
        filter/ - filters run on all messages
    man/ - man pages
    var/ - dynamic files
        root/ - user "filesystem" root

The most interesting directory tree is `var/root`, which is the root of the
"filesystem" which is visible to bot users. Beneath it there is a directory for
each room which the bot joins. Relative paths (i.e. those not containing a
directory separator: `/`) are relative to the directory corresponding to the
room from which the message originated. If the path contains a directory
separator it is considered to be absolute, and is relative to `var/root`. This
is implemented by passing all user-defined paths as an argument to the
`lib/path` binary, which returns the corrected path. It is the duty of each
command to ensure that paths are sanitized in this way.

Commands
--------

Commands must be in `bin/` and must be executable.

Commands can read from standard input and write to standard output and
error as you would expect. Return values can be inspected by the user, so if
appropriate set a non-zero exit status.

Commands receive arguments through argv as expected. If the command is written
in fish the standard `argparse` function can be used to interpret flag
arguments.

```fish
#!/usr/bin/fish

set self (basename (status -f))
argparse -n$self a b= c -- $argv >/dev/null ^&1
or begin
    printf "%s: Invalid commandline\n" $self >&2
    exit 1
end

# use $_flag_a $_flag_b and $_flag_c
```

Command output will be sent back to the room where the command was invoked.

It is each command's responsibility to ensure undue access is not granted to
the user. Specifically, path arguments which are accepted by the command *must*
be filtered through `lib/path`, and care must be taken when invoking other
commands that arguments which might be interpreted as flags are not.
