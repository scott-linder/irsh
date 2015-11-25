irsh
====

Internet Relay SHell

Usage
-----

Create a configuration file `etc/irsh.ini`:

    [irsh]
    host = localhost
    port = 6667
    nick = irsh
    user = irsh localhost localhost :irsh
    leader = $
    maxpipes = 5
    timeout = 5

The leader must prefix all commands.

Start irsh by running `init` and then message the bot to join channels:

    /msg irsh $join #channel

Rationale
---------

Both IRC and Unix shells share a line-oriented, text-based interface. Many IRC
bots follow the pattern of invoking commands and passing arguments, but do not
allow for composition of commands. The Unix shell (through pipes and
redirection) makes composition of commands and filters simple.

Thus irsh hopes to achieve the same, but in the restricted context of an IRC
channel, and with the reuse of as many Unix utilities as possible (with only
slight interface modifications).

Overview
--------

The bot's core (`init`) is written in Python3 and requires no non-standard
libraries.

The rest of the bot is intended to be written in Unix shell, specifically
[fish](http://fishshell.com/).

Filesystem
----------

The layout of the source directory is similar to a modern Unix filesystem:

    init - perhaps more aptly just `sh`
    bin/ - commands and filters
    etc/ - configuration
    lib/ - libraries (for both `init` and commands)
    usr/ - static files
        man/ - man pages
    var/ - dynamic files
        root/ - user "filesystem" root

The most interesting directory tree is `var/root`, which is the root of the
"filesystem" which is visible to bot users in channel. Beneath it there is a
directory for each channel which the bot joins. Relative paths (i.e. those not
containing a directory separator: `/`) are relative to the directory
corresponding to the channel the message originated from. If the path contains
a directory separator it is considered to be absolute, and is relative to
`var/root`. This is implemented by passing all user-defined paths as an
argument to the `lib/path` binary, which returns the corrected path. It is the
duty of each command to ensure that paths are sanitized thus.

Commands
--------

Commands must be in `bin/` and must be executable.

Commands can read from standard input and write to standard output and
error as you would expect. It is important to set a non-zero exit status if
a fatal error occurs, because otherwise the standard error is not displayed.

Commands receive arguments through argv as expected. If the command is written
in fish there is a utility library, `lib/opts.fish` which defines a function
`opts` which extracts `$flags` and `$pos` (positional arguments) from the argv
via `getopt`. An example use is:

```fish
#!/usr/bin/fish

. lib/opts.fish

opts ab:c $argv

set a
set b
set c

set i 1
while test $i -le (count $flags)
    switch $flags[$i]
        case '-a'
            set a 1
        case '-b'
            set i (math $i+1)
            set b $flags[$i]
        case '-c'
            set c 1
    end
    set i (math $i+1)
end
```

Command output will be sent back to the channel where the command was invoked,
but often commands need to execute IRC commands directly. This can be achieved
by writing to the `var/cmd` named pipe; any command written here will be sent
verbatim to the IRC server. For example, `bin/join` sends `JOIN #channel\r\n`
by writing to `var/cmd`.

It is each command's responsibility to ensure undue access is not granted to the
user. Specifically, path arguments which are accepted by the command *must* be
filtered through `lib/path`, and care must be taken when invoking other
commands that arguments which might be interpreted as flags are not.
