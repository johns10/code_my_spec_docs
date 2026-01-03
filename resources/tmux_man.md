
       new-window [-abdkPS] [-c start-directory] [-e environment] [-F
               format] [-n window-name] [-t target-window] [shell-command
               [argument ...]]
                     (alias: neww)
               Create a new window.  With -a or -b, the new window is
               inserted at the next index after or before the specified
               target-window, moving windows up if necessary; otherwise
               target-window is the new window location.

               If -d is given, the session does not make the new window
               the current window.  target-window represents the window
               to be created; if the target already exists an error is
               shown, unless the -k flag is used, in which case it is
               destroyed.  If -S is given and a window named window-name
               already exists, it is selected (unless -d is also given in
               which case the command does nothing).

               shell-command is the command to execute.  If shell-command
               is not specified, the value of the default-command option
               is used.  -c specifies the working directory in which the
               new window is created.

               When the shell command completes, the window closes.  See
               the remain-on-exit option to change this behaviour.

               -e takes the form ‘VARIABLE=value’ and sets an environment
               variable for the newly created window; it may be specified
               multiple times.

               The TERM environment variable must be set to ‘screen’ or
               ‘tmux’ for all programs running inside tmux.  New windows
               will automatically have ‘TERM=screen’ added to their
               environment, but care must be taken not to reset this in
               shell start-up files or by the -e option.

               The -P option prints information about the new window
               after it has been created.  By default, it uses the format
               ‘#{session_name}:#{window_index}’ but a different format
               may be specified with -F.

       kill-window [-a] [-t target-window]
                     (alias: killw)
               Kill the current window or the window at target-window,
               removing it from any sessions to which it is linked.  The
               -a option kills all but the window given with -t.

       send-keys [-FHKlMRX] [-c target-client] [-N repeat-count] [-t
               target-pane] [key ...]
                     (alias: send)
               Send a key or keys to a window or client.  Each argument
               key is the name of the key (such as ‘C-a’ or ‘NPage’) to
               send; if the string is not recognised as a key, it is sent
               as a series of characters.  If -K is given, keys are sent
               to target-client, so they are looked up in the client's
               key table, rather than to target-pane.  All arguments are
               sent sequentially from first to last.  If no keys are
               given and the command is bound to a key, then that key is
               used.

               The -l flag disables key name lookup and processes the
               keys as literal UTF-8 characters.  The -H flag expects
               each key to be a hexadecimal number for an ASCII
               character.

               The -R flag causes the terminal state to be reset.

               -M passes through a mouse event (only valid if bound to a
               mouse key binding, see “MOUSE SUPPORT”).

               -X is used to send a command into copy mode - see the
               “WINDOWS AND PANES” section.  -N specifies a repeat count
               and -F expands formats in arguments where appropriate.

       list-windows [-a] [-F format] [-f filter] [-t target-session]
                     (alias: lsw)
               If -a is given, list all windows on the server.
               Otherwise, list windows in the current session or in
               target-session.  -F specifies the format of each line and
               -f a filter.  Only windows for which the filter is true
               are shown.  See the “FORMATS” section.

       split-window [-bdfhIvPZ] [-c start-directory] [-e environment] [-F
               format] [-l size] [-t target-pane] [shell-command
               [argument ...]]
                     (alias: splitw)
               Create a new pane by splitting target-pane: -h does a
               horizontal split and -v a vertical split; if neither is
               specified, -v is assumed.  The -l option specifies the
               size of the new pane in lines (for vertical split) or in
               columns (for horizontal split); size may be followed by
               ‘%’ to specify a percentage of the available space.  The
               -b option causes the new pane to be created to the left of
               or above target-pane.  The -f option creates a new pane
               spanning the full window height (with -h) or full window
               width (with -v), instead of splitting the active pane.  -Z
               zooms if the window is not zoomed, or keeps it zoomed if
               already zoomed.

               An empty shell-command ('') will create a pane with no
               command running in it.  Output can be sent to such a pane
               with the display-message command.  The -I flag (if
               shell-command is not specified or empty) will create an
               empty pane and forward any output from stdin to it.  For
               example:

                     $ make 2>&1|tmux splitw -dI &

               All other options have the same meaning as for the
               new-window command.

       select-pane [-DdeLlMmRUZ] [-T title] [-t target-pane]
                     (alias: selectp)
               Make pane target-pane the active pane in its window.  If
               one of -D, -L, -R, or -U is used, respectively the pane
               below, to the left, to the right, or above the target pane
               is used.  -Z keeps the window zoomed if it was zoomed.  -l
               is the same as using the last-pane command.  -e enables or
               -d disables input to the pane.  -T sets the pane title.

               -m and -M are used to set and clear the marked pane.
               There is one marked pane at a time, setting a new marked
               pane clears the last.  The marked pane is the default
               target for -s to join-pane, move-pane, swap-pane and
               swap-window.

       copy-mode [-deHMqSu] [-s src-pane] [-t target-pane]
               Enter copy mode.

               -u enters copy mode and scrolls one page up and -d one
               page down.  -H hides the position indicator in the top
               right.  -q cancels copy mode and any other modes.

               -M begins a mouse drag (only valid if bound to a mouse key
               binding, see “MOUSE SUPPORT”).  -S scrolls when bound to a
               mouse drag event; for example, copy-mode -Se is bound to
               MouseDrag1ScrollbarSlider by default.

               -s copies from src-pane instead of target-pane.

               -e specifies that scrolling to the bottom of the history
               (to the visible screen) should exit copy mode.  While in
               copy mode, pressing a key other than those used for
               scrolling will disable this behaviour.  This is intended
               to allow fast scrolling through a pane's history, for
               example with:

                     bind PageUp copy-mode -eu
                     bind PageDown copy-mode -ed

       kill-pane [-a] [-t target-pane]
                     (alias: killp)
               Destroy the given pane.  If no panes remain in the
               containing window, it is also destroyed.  The -a option
               kills all but the pane given with -t.

       list-panes [-as] [-F format] [-f filter] [-t target]
                     (alias: lsp)
               If -a is given, target is ignored and all panes on the
               server are listed.  If -s is given, target is a session
               (or the current session).  If neither is given, target is
               a window (or the current window).  -F specifies the format
               of each line and -f a filter.  Only panes for which the
               filter is true are shown.  See the “FORMATS” section.

       break-pane [-abdP] [-F format] [-n window-name] [-s src-pane] [-t
               dst-window]
                     (alias: breakp)
               Break src-pane off from its containing window to make it
               the only pane in dst-window.  With -a or -b, the window is
               moved to the next index after or before (existing windows
               are moved if necessary).  If -d is given, the new window
               does not become the current window.  The -P option prints
               information about the new window after it has been
               created.  By default, it uses the format
               ‘#{session_name}:#{window_index}.#{pane_index}’ but a
               different format may be specified with -F.
